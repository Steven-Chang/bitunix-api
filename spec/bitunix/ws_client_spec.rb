# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bitunix::WS::FuturePrivate do
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
    if defined?(EventMachine) && EventMachine.reactor_running?
      EventMachine.stop_event_loop
    end
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
end