# frozen_string_literal: true

require "spec_helper"
require "yaml"
require "tempfile"

RSpec.describe Bitunix::Config do
  def write_temp_config(hash)
    file = Tempfile.new(["open_api_config", ".yaml"])
    file.write(hash.to_yaml)
    file.flush
    file.close
    file.path
  end

  let(:config_hash) do
    {
      "credentials" => { "api_key" => "the_key", "secret_key" => "the_secret" },
      "websocket" => { "public_uri" => "wss://pub", "private_uri" => "wss://priv", "reconnect_interval" => 7 },
      "http" => { "uri_prefix" => "https://api.example.com" }
    }
  end

  it "loads fields from yaml" do
    path = write_temp_config(config_hash)
    cfg = Bitunix::Config.new(path)

    expect(cfg.api_key).to eq("the_key")
    expect(cfg.secret_key).to eq("the_secret")
    expect(cfg.public_ws_uri).to eq("wss://pub")
    expect(cfg.private_ws_uri).to eq("wss://priv")
    expect(cfg.uri_prefix).to eq("https://api.example.com")
    expect(cfg.reconnect_interval).to eq(7)

    # get with nested key
    expect(cfg.get("websocket.private_uri")).to eq("wss://priv")
    File.delete(path)
  end

  it "raises when config file missing" do
    expect { Bitunix::Config.new("non-existent-file.yaml") }.to raise_error(Errno::ENOENT)
  end
end