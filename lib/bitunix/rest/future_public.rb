require "faraday"
require "json"

module Bitunix
  module Rest
    class FuturePublic
      def initialize
        @conn = Faraday.new(url: "https://fapi.bitunix.com") do |f|
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

      def get_tickers(symbols = nil)
        url = "/api/v1/futures/market/tickers"
        params = {}
        params["symbols"] = symbols if symbols
        query_string = Sign.sort_params(params)
        headers = Sign.get_auth_headers(query_params: query_string)
        response = @conn.get(url, params, headers)
        handle_response(response)
      end

      # https://openapidoc.bitunix.com/doc/market/get_trading_pairs.html
      def get_trading_pairs(symbols = nil)
        url = "/api/v1/futures/market/trading_pairs"
        params = {}
        params["symbols"] = symbols if symbols
        query_string = Sign.sort_params(params)
        headers = Sign.get_auth_headers(query_params: query_string)
        response = @conn.get(url, params, headers)
        handle_response(response)
      end

      def get_depth(symbol, limit = 100)
        url = "/api/v1/futures/market/depth"
        params = {"symbol" => symbol, "limit" => limit}
        query_string = Sign.sort_params(params)
        headers = Sign.get_auth_headers(query_params: query_string)
        response = @conn.get(url, params, headers)
        handle_response(response)
      end

      def get_kline(symbol:, interval:, limit: 100, start_time: nil, end_time: nil, type: "LAST_PRICE")
        url = "/api/v1/futures/market/kline"
        params = {"symbol" => symbol, "interval" => interval, "limit" => limit, "type" => type}
        params["startTime"] = start_time if start_time
        params["endTime"] = end_time if end_time
        query_string = Sign.sort_params(params)
        headers = Sign.get_auth_headers(query_params: query_string)
        response = @conn.get(url, params, headers)
        handle_response(response)
      end

      def get_batch_funding_rate(symbols = nil)
        url = "/api/v1/futures/market/funding_rate/batch"
        params = {}
        params["symbols"] = symbols if symbols
        query_string = Sign.sort_params(params)
        headers = Sign.get_auth_headers(query_params: query_string)
        response = @conn.get(url, params, headers)
        handle_response(response)
      end
    end
  end
end