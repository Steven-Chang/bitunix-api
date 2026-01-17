# frozen_string_literal: true

require "time"

module Bitunix
  module WS
    module Auth
      module_function

      # Produce WS auth payload similar to the Python demo.
      # Returns a Hash with string keys: "apiKey", "timestamp", "nonce", "sign"
      def auth_payload(api_key, secret_key)
        nonce = Bitunix::Sign.get_nonce
        timestamp = Time.now.to_i
        # Sign algorithm: sign = sha256(sha256(nonce + timestamp + api_key) + secret_key)
        inner = Bitunix::Sign.sha256_hex("#{nonce}#{timestamp}#{api_key}")
        sign = Bitunix::Sign.sha256_hex("#{inner}#{secret_key}")
        {
          "apiKey" => api_key,
          "timestamp" => timestamp,
          "nonce" => nonce,
          "sign" => sign
        }
      end
    end
  end
end