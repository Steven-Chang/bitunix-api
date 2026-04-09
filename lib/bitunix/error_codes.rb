# frozen_string_literal: true

module Bitunix
  module ErrorCode
    # Expanded mapping ported from Demo/Python/error_codes.py
    MAPPING = {
      # General error codes (10000-10099)
      0 => "Success",
      10_001 => "Network Error",
      10_002 => "Parameter Error",
      10_003 => "api-key can't be empty",
      10_004 => "The current ip is not in the apikey ip whitelist",
      10_005 => "Too many requests, please try again later",
      10_006 => "Request too frequently",
      10_007 => "Sign signature error",
      10_008 => "{value} does not comply with the rule, optional [correctValue]",

      # Market related error codes (20000-20099)
      20_001 => "Market not exists",
      20_002 => "The current positions amount has exceeded the maximum open limit, please adjust the risk limit",
      20_003 => "Insufficient balance",
      20_004 => "Insufficient Trader",
      20_005 => "Invalid leverage",
      20_006 => "You can't change leverage or margin mode as there are open orders",
      20_007 => "Order not found, please try it later",
      20_008 => "Insufficient amount",
      20_009 => "Position exists, so positions mode cannot be updated",
      20_010 => "Activation failed, the available balance in the futures account does not meet the conditions for activation of the coupon",
      20_011 => "Account not allowed to trade",
      20_012 => "This futures does not allow trading",
      20_013 => "Function disabled due tp pending account deletion request",
      20_014 => "Account deleted",
      20_015 => "This futures is not supported",

      # Trading related error codes (30000-30099)
      30_001 => "Failed to order. Please adjust the order price or the leverage as the order price dealt may immediately liquidate.",
      30_002 => "Price below liquidated price",
      30_003 => "Price above liquidated price",
      30_004 => "Position not exist",
      30_005 => "The trigger price is closer to the current price and may be triggered immediately",
      30_006 => "Please select TP or SL",
      30_007 => "TP trigger price is greater than average entry price",
      30_008 => "TP trigger price is less than average entry price",
      30_009 => "SL trigger price is less than average entry price",
      30_010 => "SL trigger price is greater than average entry price",
      30_011 => "Abnormal order status",
      30_012 => "Already added to favorite",
      30_013 => "Exceeded the maximum order quantity",
      30_014 => "Max Buy Order Price",
      30_015 => "Mini Sell Order Price",
      30_016 => "The qty should be larger than",
      30_017 => "The qty cannot be less than the minimum qty",
      30_018 => "Order failed. No position opened. Cancel [Reduce-only] settings and retry later",
      30_019 => "Order failed. A [Reduce-only] order can not be in the same direction as the open position",
      30_020 => "Trigger price for TP should be higher than mark price",
      30_021 => "Trigger price for TP should be lower than mark price",
      30_022 => "Trigger price for SL should be higher than mark price",
      30_023 => "Trigger price fo SL should be lower than mark price",
      30_024 => "Trigger price for SL should be lower than liq price",
      30_025 => "Trigger price for SL should be higher than liq price",
      30_026 => "TP price must be greater than last price",
      30_027 => "TP price must be greater than mark price",
      30_028 => "SL price must be less than last price",
      30_029 => "SL price must be less than mark price",
      30_030 => "SL price must be greater than last price",
      30_031 => "SL price must be greater than mark price",
      30_032 => "TP price must be less than last price",
      30_033 => "TP price must be less than mark price",
      30_034 => "TP price must be less than mark price",
      30_035 => "SL price must be greater than trigger price",
      30_036 => "TP price must be greater than trigger price",
      30_037 => "TP price must be greater than trigger price",
      30_038 => "TP/SL amount must be less than the size of the position",
      30_039 => "The order qty can't be greater than the max order qty",
      30_040 => "Futures trading is prohibited, please contact customer service",
      30_041 => "Trigger price must be greater than 0",
      30_042 => "Client ID duplicate",

      # Copy trading related error codes (40000-40099)
      40_001 => "Please cancel open orders and close all positions before canceling lead trading",
      40_002 => "Lead amount hast to be over the limits",
      40_003 => "Lead order amount exceeds the limits",
      40_004 => "Please do not repeat the operation",
      40_005 => "Action is not available for the current user type",
      40_006 => "Sub-account reaches the limit",
      40_007 => "Share settlement is being processed,lease try again later",
      40_008 => "After the transfer, the account balance will be less than the order amount, please enter again"
    }.freeze

    def self.get_by_code(code)
      MAPPING[code]
    end

    # Convenience method to return a structured error (optional)
    def self.error_for(code)
      msg = get_by_code(code)
      return nil unless msg

      { code: code, message: msg }
    end
  end
end
