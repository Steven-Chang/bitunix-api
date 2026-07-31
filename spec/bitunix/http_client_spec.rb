# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bitunix::Rest::Futures do
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

  describe Bitunix::Rest::Futures::Public do
    let(:client) { described_class.new(config) }

    it "get_tickers returns parsed data when API responds with code 0" do
      stub_request(:get, "https://api.example.com/api/v1/futures/market/tickers")
        .to_return(status: 200, body: { code: 0,
                                        data: { "tickers" => [1, 2,
                                                              3] } }.to_json, headers: { "Content-Type" => "application/json" })

      result = client.get_tickers("BTCUSDT")
      expect(result).to eq("tickers" => [1, 2, 3])
    end

    it "raises on HTTP error status" do
      stub_request(:get, "https://api.example.com/api/v1/futures/market/tickers")
        .to_return(status: 500, body: "server error")

      expect { client.get_tickers }.to raise_error(Bitunix::HttpError, /HTTP Error: 500/)
    end

    it "raises ApiError with code, msg and data from the response" do
      stub_request(:get, "https://api.example.com/api/v1/futures/market/tickers")
        .to_return(status: 200,
                   body: { code: 2, data: nil, msg: "must not be null" }.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect { client.get_tickers }.to raise_error do |error|
        expect(error).to be_a(Bitunix::ApiError)
        expect(error.code).to eq(2)
        expect(error.msg).to eq("must not be null")
        expect(error.data).to be_nil
        expect(error.message).to include("2")
        expect(error.message).to include("must not be null")
        expect(error.message).to include("Required parameter is missing or null")
      end
    end
  end

  describe Bitunix::Rest::Futures::Private do
    let(:client) { described_class.new(config) }

    it "get_account returns parsed data" do
      stub_request(:get, "https://api.example.com/api/v1/futures/account")
        .with(query: hash_including("marginCoin" => "USDT"))
        .to_return(status: 200, body: { code: 0,
                                        data: { "balance" => 100 } }.to_json, headers: { "Content-Type" => "application/json" })

      result = client.get_account
      expect(result).to eq("balance" => 100)
    end

    it "get_leverage_and_margin_mode returns parsed data" do
      stub_request(:get, "https://api.example.com/api/v1/futures/account/get_leverage_margin_mode")
        .with(query: hash_including("symbol" => "BTCUSDT", "marginCoin" => "USDT"))
        .to_return(status: 200, body: { code: 0,
                                        data: { "symbol" => "BTCUSDT", "marginCoin" => "USDT",
                                                "leverage" => 10, "marginMode" => "ISOLATION" } }.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = client.get_leverage_and_margin_mode("BTCUSDT")
      expect(result).to eq("symbol" => "BTCUSDT", "marginCoin" => "USDT", "leverage" => 10,
                           "marginMode" => "ISOLATION")
    end

    it "place_order posts data and returns result" do
      stub_request(:post, "https://api.example.com/api/v1/futures/trade/place_order")
        .with(body: hash_including(
          "symbol" => "BTCUSDT",
          "side" => "BUY",
          "orderType" => "LIMIT",
          "qty" => "1",
          "price" => "100",
          "tradeSide" => "OPEN",
          "effect" => "GTC",
          "reduceOnly" => false,
          "clientId" => "cid-1",
          "positionId" => "111",
          "tpPrice" => "61000",
          "tpStopType" => "MARK_PRICE",
          "tpOrderType" => "LIMIT",
          "tpOrderPrice" => "61000.1",
          "slPrice" => "59000",
          "slStopType" => "LAST_PRICE",
          "slOrderType" => "MARKET",
          "slOrderPrice" => "58900"
        ))
        .to_return(status: 200, body: { code: 0,
                                        data: { "orderId" => "abc" } }.to_json, headers: { "Content-Type" => "application/json" })

      res = client.place_order(
        symbol: "BTCUSDT",
        side: "BUY",
        order_type: "LIMIT",
        qty: "1",
        price: "100",
        position_id: "111",
        client_id: "cid-1",
        tp_price: "61000",
        tp_stop_type: "MARK_PRICE",
        tp_order_type: "LIMIT",
        tp_order_price: "61000.1",
        sl_price: "59000",
        sl_stop_type: "LAST_PRICE",
        sl_order_type: "MARKET",
        sl_order_price: "58900"
      )
      expect(res).to eq("orderId" => "abc")
    end

    it "batch_order posts symbol, marginCoin and orderList" do
      order_list = [{
        "side" => "BUY",
        "price" => "100",
        "qty" => "1",
        "orderType" => "LIMIT",
        "reduceOnly" => true
      }]
      expected_order_list = [{
        "side" => "BUY",
        "price" => "100",
        "qty" => "1",
        "orderType" => "LIMIT",
        "effect" => "GTC",
        "reduceOnly" => true
      }]

      stub_request(:post, "https://api.example.com/api/v1/futures/trade/batch_order")
        .with { |req|
          body = JSON.parse(req.body)
          body["symbol"] == "BTCUSDT" &&
            body["marginCoin"] == "USDT" &&
            body["orderList"] == expected_order_list &&
            req.headers["Content-Type"]&.include?("application/json")
        }
        .to_return(status: 200, body: { code: 0,
                                        data: { "successList" => [{ "id" => "1" }],
                                                "failureList" => [] } }.to_json,
                   headers: { "Content-Type" => "application/json" })

      res = client.batch_order("BTCUSDT", order_list, "USDT")
      expect(res).to eq("successList" => [{ "id" => "1" }], "failureList" => [])
    end

    it "batch_order normalizes ActionController-like params before signing" do
      order = Object.new
      def order.to_unsafe_h
        { side: "BUY", price: "100", qty: "1", orderType: "LIMIT", reduceOnly: "true" }
      end

      stub_request(:post, "https://api.example.com/api/v1/futures/trade/batch_order")
        .with { |req|
          body = JSON.parse(req.body)
          body["orderList"] == [{
            "side" => "BUY",
            "price" => "100",
            "qty" => "1",
            "orderType" => "LIMIT",
            "effect" => "GTC",
            "reduceOnly" => true
          }]
        }
        .to_return(status: 200, body: { code: 0, data: { "successList" => [] } }.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect(client.batch_order("BTCUSDT", [order], "USDT")).to eq("successList" => [])
    end

    it "tpsl.cancel_order posts data and returns result" do
      stub_request(:post, "https://api.example.com/api/v1/futures/tpsl/cancel_order")
        .with(body: hash_including("symbol" => "BTCUSDT", "orderId" => "12"))
        .to_return(status: 200, body: { code: 0,
                                        data: { "orderId" => "12" } }.to_json, headers: { "Content-Type" => "application/json" })

      res = client.tpsl.cancel_order("BTCUSDT", "12")
      expect(res).to eq("orderId" => "12")
    end

    it "tpsl.get_history_orders returns parsed data" do
      stub_request(:get, "https://api.example.com/api/v1/futures/tpsl/get_history_orders")
        .with(query: hash_including("symbol" => "BTCUSDT", "skip" => "0", "limit" => "10"))
        .to_return(status: 200, body: { code: 0,
                                        data: [{ "id" => "1", "symbol" => "BTCUSDT" }] }.to_json, headers: { "Content-Type" => "application/json" })

      res = client.tpsl.get_history_orders(symbol: "BTCUSDT")
      expect(res).to eq([{ "id" => "1", "symbol" => "BTCUSDT" }])
    end

    it "tpsl.get_pending_orders returns parsed data" do
      stub_request(:get, "https://api.example.com/api/v1/futures/tpsl/get_pending_orders")
        .with(query: hash_including("symbol" => "BTCUSDT", "skip" => "0", "limit" => "10"))
        .to_return(status: 200, body: { code: 0,
                                        data: [{ "id" => "123", "symbol" => "BTCUSDT" }] }.to_json, headers: { "Content-Type" => "application/json" })

      res = client.tpsl.get_pending_orders(symbol: "BTCUSDT")
      expect(res).to eq([{ "id" => "123", "symbol" => "BTCUSDT" }])
    end

    it "tpsl.position_modify_order posts data and returns result" do
      stub_request(:post, "https://api.example.com/api/v1/futures/tpsl/position/modify_order")
        .with(body: hash_including("symbol" => "BTCUSDT", "positionId" => "11", "tpPrice" => "12"))
        .to_return(status: 200, body: { code: 0,
                                        data: { "orderId" => "11111" } }.to_json, headers: { "Content-Type" => "application/json" })

      res = client.tpsl.position_modify_order("BTCUSDT", "11", tp_price: "12", tp_stop_type: "LAST_PRICE")
      expect(res).to eq("orderId" => "11111")
    end

    it "tpsl.modify_order posts data and returns result" do
      stub_request(:post, "https://api.example.com/api/v1/futures/tpsl/modify_order")
        .with(body: hash_including("orderId" => "123", "tpPrice" => "12", "slPrice" => "9"))
        .to_return(status: 200, body: { code: 0,
                                        data: { "orderId" => "123" } }.to_json, headers: { "Content-Type" => "application/json" })

      res = client.tpsl.modify_order("123", tp_price: "12", sl_price: "9", tp_qty: "1", sl_qty: "1")
      expect(res).to eq("orderId" => "123")
    end

    it "tpsl.position_place_order posts data and returns result" do
      stub_request(:post, "https://api.example.com/api/v1/futures/tpsl/position/place_order")
        .with(body: hash_including("symbol" => "BTCUSDT", "positionId" => "111", "tpPrice" => "12"))
        .to_return(status: 200, body: { code: 0,
                                        data: { "orderId" => "11111" } }.to_json, headers: { "Content-Type" => "application/json" })

      res = client.tpsl.position_place_order("BTCUSDT", "111", tp_price: "12", sl_price: "9")
      expect(res).to eq("orderId" => "11111")
    end

    it "tpsl.place_order posts data and returns result" do
      stub_request(:post, "https://api.example.com/api/v1/futures/tpsl/place_order")
        .with(body: hash_including("symbol" => "BTCUSDT", "positionId" => "111", "tpQty" => "1", "slQty" => "1"))
        .to_return(status: 200, body: { code: 0,
                                        data: { "orderId" => "11111" } }.to_json, headers: { "Content-Type" => "application/json" })

      res = client.tpsl.place_order("BTCUSDT", "111", tp_price: "12", sl_price: "9", tp_qty: "1", sl_qty: "1")
      expect(res).to eq("orderId" => "11111")
    end
  end
end
