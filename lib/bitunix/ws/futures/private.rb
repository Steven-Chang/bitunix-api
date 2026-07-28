# frozen_string_literal: true

require_relative "base"
require_relative "../auth"

module Bitunix
  module WS
    module Futures
      # EventMachine-backed WebSocket client for private channels (futures).
      #
      # Connects to the private WebSocket domain and sends a signed login on open.
      class Private < Base
        def initialize(config)
          super
          @api_key = config.api_key
          @secret_key = config.secret_key
        end

        private

        def ws_uri
          @config.private_ws_uri
        end

        def after_open
          authenticate
        end

        def authenticate
          auth = Bitunix::WS::Auth.auth_payload(@api_key, @secret_key)
          send_payload(op: "login", args: [auth])
        end
      end
    end
  end
end
