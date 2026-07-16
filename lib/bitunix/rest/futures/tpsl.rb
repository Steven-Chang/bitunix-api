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

        # https://www.bitunix.com/api-docs/futures/tp_sl/get_history_tp_sl_order.html
        def get_history_orders(symbol: nil, side: nil, position_mode: nil, start_time: nil, end_time: nil, skip: 0, limit: 10)
          url = "/api/v1/futures/tpsl/get_history_orders"
          params = { skip:, limit: }
          params[:symbol] = symbol if symbol
          params[:side] = side if side
          params[:positionMode] = position_mode if position_mode
          params[:startTime] = start_time if start_time
          params[:endTime] = end_time if end_time
          query_string = Sign.sort_params(params)
          headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, query_params: query_string)
          response = @conn.get(url, params, headers)
          @response_handler.call(response)
        end
      end
    end
  end
end
