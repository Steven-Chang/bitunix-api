require "yaml"

module Bitunix
  class Config
    attr_reader :api_key, :secret_key, :public_ws_uri, :private_ws_uri, :reconnect_interval, :uri_prefix

    def initialize(path)
      raw = YAML.load_file(path)
      @data = raw.is_a?(Hash) ? raw : {}

      credentials = fetch_hash(@data, "credentials")
      websocket = fetch_hash(@data, "websocket")
      http = fetch_hash(@data, "http")

      @api_key = credentials["api_key"]
      @secret_key = credentials["secret_key"]
      @public_ws_uri = websocket["public_uri"]
      @private_ws_uri = websocket["private_uri"]
      @reconnect_interval = websocket["reconnect_interval"]
      @uri_prefix = http["uri_prefix"] || "https://fapi.bitunix.com"
    end

    def get(path)
      return nil if path.nil? || path.to_s.empty?

      path.to_s.split(".").reduce(@data) do |memo, key|
        memo.is_a?(Hash) ? memo[key] : nil
      end
    end

    private

    def fetch_hash(source, key)
      value = source[key]
      value.is_a?(Hash) ? value : {}
    end
  end
end
