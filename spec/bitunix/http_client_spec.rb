# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bitunix::Rest do
  let(:tmpfile) do
    f = Tempfile.new(["cfg", ".yaml"])
    f.write({
      "credentials" => { "api_key" => "AK", "secret_key" => "SK" },
      "http" => { "uri_prefix" => "https://api.example.com" }
    }.to_yaml)
    f.flush
    f.close
    f.path
  end

  let(:config) { Bitunix::Config.new(tmpfile) }

  describe Bitunix::Rest::FuturePublic do
    let(:client) { described_class.new(config) }

    it "get_tickers returns parsed data when API responds with code 0" do
      stub_request(:get, "https://api.example.com/api/v1/futures/market/tickers")
        .to_return(status: 200, body: { code: 0, data: { "tickers" => [1, 2, 3] } }.to_json, headers: { "Content-Type" => "application/json" })

      result = client.get_tickers("BTCUSDT")
      expect(result).to eq("tickers" => [1, 2, 3])
    end

    it "raises on HTTP error status" do
      stub_request(:get, "https://api.example.com/api/v1/futures/market/tickers")
        .to_return(status: 500, body: "server error")

      expect { client.get_tickers }.to raise_error(RuntimeError, /HTTP Error:/)
    end
  end

  describe Bitunix::Rest::FuturePrivate do
    let(:client) { described_class.new(config) }

    it "get_account returns parsed data" do
      stub_request(:get, "https://api.example.com/api/v1/futures/account")
        .with(query: hash_including("marginCoin" => "USDT"))
        .to_return(status: 200, body: { code: 0, data: { "balance" => 100 } }.to_json, headers: { "Content-Type" => "application/json" })

      result = client.get_account
      expect(result).to eq("balance" => 100)
    end

    it "place_order posts data and returns result" do
      stub_request(:post, "https://api.example.com/api/v1/futures/trade/place_order")
        .to_return(status: 200, body: { code: 0, data: { "orderId" => "abc" } }.to_json, headers: { "Content-Type" => "application/json" })

      res = client.place_order(symbol: "BTCUSDT", side: "BUY", order_type: "LIMIT", qty: "1", price: "100")
      expect(res).to eq("orderId" => "abc")
    end
  end
end