# frozen_string_literal: true

require_relative "base"

module Bitunix
  module WS
    module Futures
      # EventMachine-backed WebSocket client for public market-data channels (futures).
      #
      # Connects to the public WebSocket domain and does not perform login.
      # Channel args are passed through as Bitunix documents them, e.g.:
      #   [{ "symbol" => "BTCUSDT", "ch" => "market_kline_1min" }]
      #   [{ "symbol" => "BTCUSDT", "ch" => "depth_books" }]
      class Public < Base
        private

        def ws_uri
          @config.public_ws_uri
        end
      end
    end
  end
end
