require "securerandom"
require "digest"
require "time"

module Bitunix
  module WS
    module Sign
      module_function

      def generate_nonce
        SecureRandom.alphanumeric(32)
      end

      def generate_timestamp
        Time.now.to_i.to_s
      end

      def sha256_hex(input)
        Digest::SHA256.hexdigest(input.to_s)
      end

      def generate_sign(nonce:, timestamp:, api_key:, secret_key:)
        digest_input = nonce.to_s + timestamp.to_s + api_key.to_s
        digest = sha256_hex(digest_input)
        sha256_hex(digest + secret_key.to_s)
      end

      def get_auth_ws_future(api_key, secret_key)
        nonce = generate_nonce
        timestamp = generate_timestamp
        sign = generate_sign(nonce: nonce, timestamp: timestamp, api_key: api_key, secret_key: secret_key)
        {
          "apiKey" => api_key,
          "timestamp" => timestamp.to_i,
          "nonce" => nonce,
          "sign" => sign
        }
      end
    end
  end
end