# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bitunix::Rest::JsonBody do
  describe ".normalize_batch_order_list" do
    it "converts parameter-like objects into plain string-keyed hashes" do
      order = Object.new
      def order.to_unsafe_h
        {
          side: "BUY",
          price: "0.07509",
          qty: "23",
          orderType: "LIMIT",
          tradeSide: "OPEN",
          reduceOnly: "true"
        }
      end

      expect(described_class.normalize_batch_order_list([order])).to eq(
        [
          {
            "side" => "BUY",
            "price" => "0.07509",
            "qty" => "23",
            "orderType" => "LIMIT",
            "effect" => "GTC",
            "tradeSide" => "OPEN",
            "reduceOnly" => true
          }
        ]
      )
    end

    it "defaults effect to GTC and casts reduceOnly" do
      expect(
        described_class.normalize_batch_order(
          "side" => "SELL",
          "price" => "1",
          "qty" => "2",
          "orderType" => "LIMIT",
          "reduceOnly" => false
        )
      ).to include("effect" => "GTC", "reduceOnly" => false)
    end

    it "omits blank optional fields" do
      order = described_class.normalize_batch_order(
        "side" => "BUY",
        "qty" => "1",
        "orderType" => "MARKET",
        "clientId" => nil,
        "tradeSide" => ""
      )

      expect(order).not_to have_key("clientId")
      expect(order).not_to have_key("tradeSide")
    end
  end
end
