# frozen_string_literal: true

module Bitunix
  # Unified REST client with market namespaces.
  #
  #   client = Bitunix::Client.new(config)
  #   client.futures.get_tickers("BTCUSDT")
  #   client.spot.query_token_data
  #
  class Client
    def initialize(config_or_api_key = nil, secret_key = nil)
      @config_or_api_key = config_or_api_key
      @secret_key = secret_key
    end

    # Futures REST (public + private). Private inherits Public methods.
    def futures
      @futures ||= Rest::Futures::Private.new(@config_or_api_key, @secret_key)
    end

    # Spot REST (public for now; private can be added later under the same accessor).
    def spot
      @spot ||= Rest::Spot::Public.new(config)
    end

    private

    def config
      return @config_or_api_key if config?

      nil
    end

    def config?
      @config_or_api_key.respond_to?(:api_key) && @config_or_api_key.respond_to?(:secret_key)
    end
  end
end
