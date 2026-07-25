# frozen_string_literal: true

require "spec_helper"
require "yaml"
require "tempfile"

RSpec.describe Bitunix::Client do
  def write_temp_config(hash)
    file = Tempfile.new(["open_api_config", ".yaml"])
    file.write(hash.to_yaml)
    file.flush
    file.close
    file.path
  end

  let(:config_hash) do
    {
      "credentials" => { "api_key" => "AK", "secret_key" => "SK" },
      "http" => {
        "futures_uri_prefix" => "https://futures.example.com",
        "spot_uri_prefix" => "https://spot.example.com"
      }
    }
  end

  let(:config) { Bitunix::Config.new(write_temp_config(config_hash)) }
  let(:client) { described_class.new(config) }

  it "exposes futures and spot namespaces from one client" do
    expect(client.futures).to be_a(Bitunix::Rest::Futures::Private)
    expect(client.spot).to be_a(Bitunix::Rest::Spot::Public)
  end

  it "memoizes futures and spot clients" do
    expect(client.futures).to equal(client.futures)
    expect(client.spot).to equal(client.spot)
  end

  it "routes futures requests to the futures base URL" do
    stub_request(:get, "https://futures.example.com/api/v1/futures/market/tickers")
      .to_return(status: 200, body: { code: 0, data: { "tickers" => [] } }.to_json,
                 headers: { "Content-Type" => "application/json" })

    expect(client.futures.get_tickers).to eq("tickers" => [])
  end

  it "routes spot requests to the spot base URL" do
    stub_request(:get, "https://spot.example.com/api/spot/v1/common/coin/coin_network/list")
      .to_return(status: 200, body: { code: 0, data: [{ "name" => "USDT" }] }.to_json,
                 headers: { "Content-Type" => "application/json" })

    expect(client.spot.query_token_data).to eq([{ "name" => "USDT" }])
  end

  it "accepts api_key and secret_key directly for futures" do
    key_client = described_class.new("AK", "SK")
    stub_request(:get, "https://fapi.bitunix.com/api/v1/futures/account")
      .with(query: hash_including("marginCoin" => "USDT"))
      .to_return(status: 200, body: { code: 0, data: { "balance" => 1 } }.to_json,
                 headers: { "Content-Type" => "application/json" })

    expect(key_client.futures.get_account).to eq("balance" => 1)
  end
end
