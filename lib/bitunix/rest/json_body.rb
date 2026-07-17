# frozen_string_literal: true

module Bitunix
  module Rest
    # Converts Rails-ish request params into plain hashes suitable for JSON.generate
    # and Bitunix request signing. ActionController::Parameters otherwise serialize as {}.
    module JsonBody
      module_function

      def plain_hash(value)
        if value.respond_to?(:to_unsafe_h)
          value.to_unsafe_h
        elsif value.respond_to?(:to_h) && !value.is_a?(Array)
          value.to_h
        else
          value
        end
      end

      def stringify_keys(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, nested), result|
            result[key.to_s] = stringify_keys(nested)
          end
        when Array
          value.map { |item| stringify_keys(item) }
        else
          value
        end
      end

      def cast_bool(value)
        case value
        when true, false
          value
        when nil
          false
        else
          %w[1 true t yes y].include?(value.to_s.strip.downcase)
        end
      end

      # Builds a signed-safe orderList entry for batch_order.
      def normalize_batch_order(order)
        raw = stringify_keys(plain_hash(order))
        {
          "side" => raw["side"],
          "price" => raw["price"],
          "qty" => raw["qty"],
          "orderType" => raw["orderType"],
          "effect" => raw["effect"].nil? || raw["effect"].to_s.empty? ? "GTC" : raw["effect"],
          "clientId" => raw["clientId"],
          "tradeSide" => raw["tradeSide"],
          "positionId" => raw["positionId"],
          "reduceOnly" => cast_bool(raw["reduceOnly"]),
          "tpPrice" => raw["tpPrice"],
          "tpStopType" => raw["tpStopType"],
          "tpOrderType" => raw["tpOrderType"],
          "tpOrderPrice" => raw["tpOrderPrice"],
          "slPrice" => raw["slPrice"],
          "slStopType" => raw["slStopType"],
          "slOrderType" => raw["slOrderType"],
          "slOrderPrice" => raw["slOrderPrice"]
        }.reject { |_, value| value.nil? || value == "" }
      end

      def normalize_batch_order_list(order_list)
        Array(order_list).map { |order| normalize_batch_order(order) }
      end
    end
  end
end
