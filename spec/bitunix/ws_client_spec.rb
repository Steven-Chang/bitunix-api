# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bitunix::WS::Futures::Private do
  let(:tmpfile) do
    f = Tempfile.new(["cfg", ".yaml"])
    f.write({
      "credentials" => { "api_key" => "AK", "secret_key" => "SK" },
      "websocket" => { "private_uri" => "wss://example.local" },
      "http" => { "uri_prefix" => "https://api.example.com" }
    }.to_yaml)
    f.flush
    f.close
    f.path
  end

  let(:config) { Bitunix::Config.new(tmpfile) }
  let(:client) { described_class.new(config) }

  after do
    # ensure we don't leave EM running in case any test started it
    EventMachine.stop_event_loop if defined?(EventMachine) && EventMachine.reactor_running?
  end

  describe ".auth_payload" do
    it "returns a hash with apiKey, timestamp, nonce and sign" do
      payload = Bitunix::WS.auth_payload("AK", "SK")
      expect(payload).to include("apiKey" => "AK", "nonce" => nil)
      expect(payload["timestamp"]).to be_a(Integer).or be_a(Numeric)
      expect(payload["sign"]).to match(/\A[0-9a-f]{64}\z/)
    end
  end

  describe "#subscribe buffering" do
    it "buffers subscriptions when not connected" do
      channels = [{ "ch" => "balance" }]
      client.subscribe(channels)
      pending = client.instance_variable_get(:@pending_subscriptions)
      expect(pending).to include(channels)
    end
  end

  it "uses the private websocket URI" do
    expect(client.instance_variable_get(:@uri)).to eq("wss://example.local")
  end
end

RSpec.describe Bitunix::WS::Futures::Public do
  let(:tmpfile) do
    f = Tempfile.new(["cfg", ".yaml"])
    f.write({
      "credentials" => { "api_key" => "AK", "secret_key" => "SK" },
      "websocket" => {
        "public_uri" => "wss://public.example.local",
        "private_uri" => "wss://private.example.local"
      },
      "http" => { "uri_prefix" => "https://api.example.com" }
    }.to_yaml)
    f.flush
    f.close
    f.path
  end

  let(:config) { Bitunix::Config.new(tmpfile) }
  let(:client) { described_class.new(config) }

  after do
    EventMachine.stop_event_loop if defined?(EventMachine) && EventMachine.reactor_running?
  end

  it "uses the public websocket URI" do
    expect(client.instance_variable_get(:@uri)).to eq("wss://public.example.local")
  end

  describe "#subscribe buffering" do
    it "buffers subscriptions when not connected" do
      channels = [{ "symbol" => "BTCUSDT", "ch" => "market_kline_1min" }]
      client.subscribe(channels)
      pending = client.instance_variable_get(:@pending_subscriptions)
      expect(pending).to include(channels)
    end
  end

  it "does not send a login payload after open" do
    expect(client).not_to receive(:send_payload).with(hash_including(op: "login"))
    client.send(:after_open)
  end
end
