# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bitunix::Sign do
  let(:api_key) { "AK" }
  let(:secret_key) { "SK" }
  let(:nonce) { "nonce123" }
  let(:timestamp) { "1610000000000" }
  let(:query_params) { "a1b2" }
  let(:body) { '{"x":1}' }

  describe ".sort_params" do
    it "sorts and concatenates params" do
      params = { "b" => "2", "a" => "1" }
      expect(Bitunix::Sign.sort_params(params)).to eq("a1b2")
    end

    it "returns empty string for nil/empty" do
      expect(Bitunix::Sign.sort_params({})).to eq("")
      expect(Bitunix::Sign.sort_params(nil)).to eq("")
    end
  end

  describe ".generate_signature" do
    it "produces a deterministic sha256-based signature for given inputs" do
      sig = Bitunix::Sign.generate_signature(
        api_key: api_key,
        secret_key: secret_key,
        nonce: nonce,
        timestamp: timestamp,
        query_params: query_params,
        body: body
      )

      # compute expected using same algorithm (mirrors implementation)
      digest_input = "#{nonce}#{timestamp}#{api_key}#{query_params}#{body}"
      expected = Bitunix::Sign.sha256_hex(Bitunix::Sign.sha256_hex(digest_input) + secret_key)

      expect(sig).to eq(expected)
      expect(sig.length).to eq(64)
      expect(sig).to match(/\A[0-9a-f]{64}\z/)
    end
  end

  describe ".get_auth_headers" do
    it "returns required authentication headers" do
      headers = Bitunix::Sign.get_auth_headers(api_key: api_key, secret_key: secret_key, query_params: "", body: "")
      expect(headers).to include("api-key", "sign", "nonce", "timestamp")
      expect(headers["api-key"]).to eq(api_key)
      expect(headers["sign"]).to match(/\A[0-9a-f]{64}\z/)
    end
  end
end