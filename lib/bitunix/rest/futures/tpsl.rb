# frozen_string_literal: true

module Bitunix
  module Rest
    module Futures
      class Tpsl
        def initialize(conn:, api_key:, secret_key:, response_handler:)
          @conn = conn
          @api_key = api_key
          @secret_key = secret_key
          @response_handler = response_handler
        end

        # https://www.bitunix.com/api-docs/futures/tp_sl/cancel_tp_sl_order.html
        def cancel_order(symbol, order_id)
          url = "/api/v1/futures/tpsl/cancel_order"
          data = { "symbol" => symbol, "orderId" => order_id }
          body = JSON.generate(data)
          headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, body: body)
          response = @conn.post(url, data, headers)
          @response_handler.call(response)
        end
      end
    end
  end
end
