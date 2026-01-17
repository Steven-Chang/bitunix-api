# frozen_string_literal: true

require "json"
require "thread"
require "eventmachine"
require "websocket-eventmachine-client"
require_relative "auth"

module Bitunix
  module WS
    # EventMachine-backed WebSocket client for private channels (futures).
    #
    # Designed to be safe to use in apps that do or do not already run an EM reactor.
    # - Starts a reactor thread if none exists.
    # - Reconnects automatically on close/error.
    # - Buffers subscribe requests until connected.
    # - Provides callback hooks: on_open, on_message, on_close, on_error.
    class FuturePrivate
      DEFAULT_HEARTBEAT_INTERVAL = 3

      attr_reader :connected

      def initialize(config)
        @config = config
        @uri = config.private_ws_uri
        @api_key = config.api_key
        @secret_key = config.secret_key
        @reconnect_interval = config.reconnect_interval || 5
        @heartbeat_interval = DEFAULT_HEARTBEAT_INTERVAL

        @ws = nil
        @connected = false

        @pending_subscriptions = []
        @send_queue = Queue.new

        @em_thread = nil
        @started_em_here = false

        @ping_timer = nil
        @reconnect_timer = nil

        @mutex = Mutex.new

        @on_message_block = nil
        @on_open_block = nil
        @on_close_block = nil
        @on_error_block = nil
      end

      # Callback registration
      def on_message(&block); @on_message_block = block; end
      def on_open(&block);    @on_open_block = block;    end
      def on_close(&block);   @on_close_block = block;   end
      def on_error(&block);   @on_error_block = block;   end

      # Start connection (and EM if needed)
      def connect
        @mutex.synchronize do
          return if @connected || connecting?
          start_em_unless_running
          schedule_connect
        end
      end

      # Subscribe to channels (array of hashes). Will buffer if not connected.
      def subscribe(channels)
        if @connected && @ws
          send_payload({ op: "subscribe", args: channels })
        else
          @pending_subscriptions << channels
        end
      end

      # Gracefully close and stop EM if started here
      def close
        @mutex.synchronize do
          if @ws
            begin
              @ws.close
            rescue StandardError => e
              warn "Error closing websocket: #{e}"
            ensure
              @ws = nil
            end
          end

          cancel_ping_timer
          cancel_reconnect_timer

          if @started_em_here && EventMachine.reactor_running?
            EventMachine.stop_event_loop
            @em_thread.join if @em_thread
            @em_thread = nil
            @started_em_here = false
          end

          @connected = false
        end
      end

      private

      def connecting?
        @reconnect_timer || (@ws && !@connected)
      end

      def start_em_unless_running
        return if EventMachine.reactor_running?

        @started_em_here = true
        @em_thread = Thread.new do
          Thread.current[:name] = "open_api_em"
          EventMachine.run
        end

        sleep 0.01 until EventMachine.reactor_running?
      end

      def schedule_connect(delay = 0)
        EventMachine.next_tick do
          if delay > 0
            @reconnect_timer = EventMachine.add_timer(delay) { do_connect }
          else
            do_connect
          end
        end
      end

      def do_connect
        @reconnect_timer = nil
        begin
          @ws = WebSocket::EventMachine::Client.connect(uri: @uri)

          @ws.onopen do |_handshake|
            @connected = true
            start_ping_timer
            authenticate
            drain_pending_subscriptions
            drain_send_queue
            @on_open_block&.call
          end

          @ws.onmessage do |msg|
            handle_message(msg.data)
          end

          @ws.onclose do |e|
            @connected = false
            cancel_ping_timer
            @on_close_block&.call(e)
            schedule_connect(@reconnect_interval)
          end

          @ws.onerror do |e|
            @on_error_block&.call(e)
            schedule_connect(@reconnect_interval) unless @connected
          end
        rescue StandardError => e
          warn "Failed to establish websocket connection: #{e}"
          schedule_connect(@reconnect_interval)
        end
      end

      def authenticate
        auth = Bitunix::WS::Auth.auth_payload(@api_key, @secret_key)
        send_payload(op: "login", args: [auth])
      end

      def send_payload(payload)
        json = payload.is_a?(String) ? payload : JSON.generate(payload)
        if @connected && @ws
          begin
            @ws.send json
          rescue StandardError => e
            @send_queue << json
            warn "Send failed, queued for retry: #{e}"
          end
        else
          @send_queue << json
        end
      end

      def drain_send_queue
        until @send_queue.empty?
          json = @send_queue.pop(true) rescue nil
          break unless json
          begin
            @ws.send json
          rescue StandardError => e
            warn "Failed sending queued message: #{e}"
            @send_queue << json
            break
          end
        end
      end

      def drain_pending_subscriptions
        until @pending_subscriptions.empty?
          channels = @pending_subscriptions.shift
          send_payload({ op: "subscribe", args: channels })
        end
      end

      def handle_message(raw)
        begin
          data = JSON.parse(raw)
          return if data["op"] == "ping"
          if @on_message_block
            @on_message_block.call(data)
          else
            puts "Received: #{data}"
          end
        rescue JSON::ParserError
          warn "Invalid JSON message"
        rescue StandardError => e
          warn "Error handling message: #{e}"
        end
      end

      def start_ping_timer
        cancel_ping_timer
        @ping_timer = EventMachine.add_periodic_timer(@heartbeat_interval) do
          begin
            send_payload(op: "ping", ping: Time.now.to_i)
          rescue StandardError => e
            warn "Ping failed: #{e}"
          end
        end
      end

      def cancel_ping_timer
        if @ping_timer
          begin
            @ping_timer.cancel
          rescue StandardError
            # ignore
          ensure
            @ping_timer = nil
          end
        end
      end

      def cancel_reconnect_timer
        if @reconnect_timer
          begin
            @reconnect_timer.cancel
          rescue StandardError
            # ignore
          ensure
            @reconnect_timer = nil
          end
        end
      end
    end
  end
end