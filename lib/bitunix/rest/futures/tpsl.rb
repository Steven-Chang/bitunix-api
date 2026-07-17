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

        # https://www.bitunix.com/api-docs/futures/tp_sl/get_pending_tp_sl_order.html
        def get_pending_orders(symbol: nil, position_id: nil, side: nil, position_mode: nil, skip: 0, limit: 10)
          url = "/api/v1/futures/tpsl/get_pending_orders"
          params = { skip:, limit: }
          params[:symbol] = symbol if symbol
          params[:positionId] = position_id if position_id
          params[:side] = side if side
          params[:positionMode] = position_mode if position_mode
          query_string = Sign.sort_params(params)
          headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, query_params: query_string)
          response = @conn.get(url, params, headers)
          @response_handler.call(response)
        end

        # https://www.bitunix.com/api-docs/futures/tp_sl/modify_position_tp_sl_order.html
        def position_modify_order(symbol, position_id, tp_price: nil, tp_stop_type: nil, sl_price: nil, sl_stop_type: nil)
          url = "/api/v1/futures/tpsl/position/modify_order"
          data = { "symbol" => symbol, "positionId" => position_id }
          data["tpPrice"] = tp_price if tp_price
          data["tpStopType"] = tp_stop_type if tp_stop_type
          data["slPrice"] = sl_price if sl_price
          data["slStopType"] = sl_stop_type if sl_stop_type
          body = JSON.generate(data)
          headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, body: body)
          response = @conn.post(url, data, headers)
          @response_handler.call(response)
        end

        # https://www.bitunix.com/api-docs/futures/tp_sl/modify_tp_sl_order.html
        def modify_order(order_id, tp_price: nil, tp_stop_type: nil, sl_price: nil, sl_stop_type: nil,
                         tp_order_type: nil, tp_order_price: nil, sl_order_type: nil, sl_order_price: nil,
                         tp_qty: nil, sl_qty: nil)
          url = "/api/v1/futures/tpsl/modify_order"
          data = { "orderId" => order_id }
          data["tpPrice"] = tp_price if tp_price
          data["tpStopType"] = tp_stop_type if tp_stop_type
          data["slPrice"] = sl_price if sl_price
          data["slStopType"] = sl_stop_type if sl_stop_type
          data["tpOrderType"] = tp_order_type if tp_order_type
          data["tpOrderPrice"] = tp_order_price if tp_order_price
          data["slOrderType"] = sl_order_type if sl_order_type
          data["slOrderPrice"] = sl_order_price if sl_order_price
          data["tpQty"] = tp_qty if tp_qty
          data["slQty"] = sl_qty if sl_qty
          body = JSON.generate(data)
          headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, body: body)
          response = @conn.post(url, data, headers)
          @response_handler.call(response)
        end

        # https://www.bitunix.com/api-docs/futures/tp_sl/place_position_tp_sl_order.html
        def position_place_order(symbol, position_id, tp_price: nil, tp_stop_type: nil, sl_price: nil, sl_stop_type: nil)
          url = "/api/v1/futures/tpsl/position/place_order"
          data = { "symbol" => symbol, "positionId" => position_id }
          data["tpPrice"] = tp_price if tp_price
          data["tpStopType"] = tp_stop_type if tp_stop_type
          data["slPrice"] = sl_price if sl_price
          data["slStopType"] = sl_stop_type if sl_stop_type
          body = JSON.generate(data)
          headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, body: body)
          response = @conn.post(url, data, headers)
          @response_handler.call(response)
        end

        # https://www.bitunix.com/api-docs/futures/tp_sl/place_tp_sl_order.html
        def place_order(symbol, position_id, tp_price: nil, tp_stop_type: nil, sl_price: nil, sl_stop_type: nil,
                        tp_order_type: nil, tp_order_price: nil, sl_order_type: nil, sl_order_price: nil,
                        tp_qty: nil, sl_qty: nil)
          url = "/api/v1/futures/tpsl/place_order"
          data = { "symbol" => symbol, "positionId" => position_id }
          data["tpPrice"] = tp_price if tp_price
          data["tpStopType"] = tp_stop_type if tp_stop_type
          data["slPrice"] = sl_price if sl_price
          data["slStopType"] = sl_stop_type if sl_stop_type
          data["tpOrderType"] = tp_order_type if tp_order_type
          data["tpOrderPrice"] = tp_order_price if tp_order_price
          data["slOrderType"] = sl_order_type if sl_order_type
          data["slOrderPrice"] = sl_order_price if sl_order_price
          data["tpQty"] = tp_qty if tp_qty
          data["slQty"] = sl_qty if sl_qty
          body = JSON.generate(data)
          headers = Sign.get_auth_headers(api_key: @api_key, secret_key: @secret_key, body: body)
          response = @conn.post(url, data, headers)
          @response_handler.call(response)
        end
      end
    end
  end
end
