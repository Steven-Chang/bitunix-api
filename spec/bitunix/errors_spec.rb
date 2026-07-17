# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bitunix::ApiError do
  it "exposes code, msg and data from the API payload" do
    error = described_class.new("code" => 2, "msg" => "must not be null", "data" => nil)

    expect(error.code).to eq(2)
    expect(error.msg).to eq("must not be null")
    expect(error.data).to be_nil
    expect(error.response).to eq("code" => 2, "msg" => "must not be null", "data" => nil)
    expect(error.message).to eq(
      "Bitunix API error 2: Required parameter is missing or null: must not be null"
    )
  end

  it "includes data when present" do
    error = described_class.new(
      "code" => 10_002,
      "msg" => "Parameter Error",
      "data" => { "field" => "marginCoin" }
    )

    expect(error.message).to include('data={"field"=>"marginCoin"}')
  end

  it "falls back to the API msg when the code is unknown" do
    error = described_class.new("code" => 99_999, "msg" => "something broke", "data" => nil)

    expect(error.message).to eq("Bitunix API error 99999: something broke")
  end
end
