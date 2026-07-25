# frozen_string_literal: true

require "faraday"
require "json"

module Bitunix
  module Rest
    module Spot
      class Public
        def initialize(config = nil)
          base_url = config&.uri_prefix || "https://openapi.bitunix.com"
          @conn = Faraday.new(url: base_url) do |f|
            f.request :json
            f.adapter Faraday.default_adapter
          end
        end

        def handle_response(response)
          raise HttpError.new(response.status, response.body) unless response.status == 200

          data = JSON.parse(response.body)
          raise ApiError, data if data["code"].to_i != 0

          data["data"]
        end

        # https://www.bitunix.com/api-docs/spots/en_us/public/#7-query-token-data
        def query_token_data
          url = "/api/spot/v1/common/coin/coin_network/list"
          headers = Sign.get_auth_headers
          response = @conn.get(url, {}, headers)
          handle_response(response)
        end
      end
    end
  end
end
