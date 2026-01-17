# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bitunix::ErrorCode do
  describe ".get_by_code" do
    it "returns the message for a known code" do
      expect(Bitunix::ErrorCode.get_by_code(10001)).to eq("Network Error")
      expect(Bitunix::ErrorCode.get_by_code(20003)).to eq("Insufficient balance")
      expect(Bitunix::ErrorCode.get_by_code(30042)).to eq("Client ID duplicate")
    end

    it "returns nil for unknown codes" do
      expect(Bitunix::ErrorCode.get_by_code(99999)).to be_nil
    end
  end

  describe ".error_for" do
    it "returns structured hash for known code" do
      h = Bitunix::ErrorCode.error_for(10001)
      expect(h).to eq(code: 10001, message: "Network Error")
    end

    it "returns nil for unknown code" do
      expect(Bitunix::ErrorCode.error_for(12345)).to be_nil
    end
  end
end