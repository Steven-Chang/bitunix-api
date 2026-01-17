require "faraday"
require "json"

module Bitunix
  module Rest
    class FuturePrivate < FuturePublic
      def initialize(api_key, secret_key)
        @api_key = api_key
        @secret_key = secret_key
        @base_url = "https://fapi.bitunix.com"
        @conn = Faraday.new(url: @base_url) do |f|
          f.request :json
          f.response :raise_error
          f.adapter Faraday.default_adapter
        end
      end

      def handle_response(response)
        unless response.status == 200
          raise "HTTP Error: #{response.status}"
        end

        data = JSON.parse(response.body)
        if data["code"] != 0
          error = ErrorCode.get_by_code(data["code"])
          raise error || "Unknown Error: #{data['code']} - #{data['msg']}"
        end

        data["data"]
      end

      def get_account(margin_coin = "USDT")
        url = "/api/v1/futures/account"
        params = {"marginCoin" => margin_coin}
        query_string = Sign.sort_params(params)
        headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, query_params: query_string)
        response = @conn.get(url, params, headers)
        handle_response(response)
      end

      def place_order(symbol:, side:, order_type:, qty:, price: nil, position_id: nil, trade_side: "OPEN", effect: "GTC", reduce_only: false, client_id: nil, tp_price: nil, tp_stop_type: nil, tp_order_type: nil, tp_order_price: nil)
        url = "/api/v1/futures/trade/place_order"
        data = {
          "symbol" => symbol,
          "side" => side,
          "orderType" => order_type,
          "qty" => qty,
          "tradeSide" => trade_side,
          "effect" => effect,
          "reduceOnly" => reduce_only
        }
        data["price"] = price if price
        data["positionId"] = position_id if position_id
        data["clientId"] = client_id if client_id
        data["tpPrice"] = tp_price if tp_price
        data["tpStopType"] = tp_stop_type if tp_stop_type
        data["tpOrderType"] = tp_order_type if tp_order_type
        data["tpOrderPrice"] = tp_order_price if tp_order_price

        body = JSON.generate(data)
        headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, body: body)
        response = @conn.post(url, data, headers)
        handle_response(response)
      end

      def cancel_orders(symbol:, order_list:)
        url = "/api/v1/futures/trade/cancel_orders"
        data = {"symbol" => symbol, "orderList" => order_list}
        body = JSON.generate(data)
        headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, body: body)
        response = @conn.post(url, data, headers)
        handle_response(response)
      end

      def get_history_orders(symbol = nil)
        url = "/api/v1/futures/trade/get_history_orders"
        params = {}
        params["symbol"] = symbol if symbol
        query_string = Sign.sort_params(params)
        headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, query_params: query_string)
        response = @conn.get(url, params, headers)
        handle_response(response)
      end

      def get_history_positions(symbol = nil)
        url = "/api/v1/futures/position/get_history_positions"
        params = {}
        params["symbol"] = symbol if symbol
        query_string = Sign.sort_params(params)
        headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, query_params: query_string)
        response = @conn.get(url, params, headers)
        handle_response(response)
      end
    end
  end
end