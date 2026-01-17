require "securerandom"
require "digest"

module Bitunix
  module Rest
    module Sign
      module_function

      def get_nonce
        SecureRandom.hex(16) # 32 chars
      end

      def get_timestamp_ms
        (Time.now.to_f * 1000).to_i.to_s
      end

      def sha256_hex(str)
        Digest::SHA256.hexdigest(str.to_s)
      end

      # Query params should already be sorted & concatenated
      def generate_signature(api_key:, secret_key:, nonce:, timestamp:, query_params: "", body: "")
        digest_input = nonce.to_s + timestamp.to_s + api_key.to_s + query_params.to_s + body.to_s
        digest = sha256_hex(digest_input)
        sha256_hex(digest + secret_key.to_s)
      end

      def get_auth_headers(api_key: nil, secret_key: nil, query_params: "", body: "")
        nonce = get_nonce
        timestamp = get_timestamp_ms
        sign = generate_signature(api_key: api_key, secret_key: secret_key, nonce: nonce, timestamp: timestamp, query_params: query_params, body: body)
        {
          "api-key" => api_key,
          "sign" => sign,
          "nonce" => nonce,
          "timestamp" => timestamp
        }
      end

      def sort_params(params)
        return "" if params.nil? || params.empty?
        params.sort.to_h.map { |k, v| "#{k}#{v}" }.join
      end
    end
  end
end