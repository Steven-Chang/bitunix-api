# Bitunix::Api

This gem is a Ruby demo port of the Demo/Python directory from the Bitunix open-api repository.

It provides:
- Config: reading `config.yaml`
- HTTP clients: Bitunix::Rest::FuturePublic and Bitunix::Rest::FuturePrivate
- WebSocket client skeleton: Bitunix::WS::FuturePrivate
- Signing utilities: Bitunix::Sign

Installation (development)
```bash
# install gem dependencies
bundle install

# or build the gem
gem build open_api.gemspec
```

Usage (example)
```ruby
require "open_api"

config = Bitunix::Config.new("config.yaml")
public_client = Bitunix::Rest::FuturePublic.new(config)
tickers = public_client.get_tickers("BTCUSDT,ETHUSDT")

private_client = Bitunix::Rest::FuturePrivate.new(config)
account = private_client.get_account

ws = Bitunix::WS::FuturePrivate.new(config)
ws.connect
ws.subscribe([{ "ch" => "balance" }, { "ch" => "position" }])
```

Notes
- This is a demo scaffold. Adapt and harden for production use (timeouts, retries, logging, thread-safety, tests).
- The error codes mapping is a placeholder in `lib/open_api/error_codes.rb`.
- The WebSocket implementation uses `websocket-client-simple`. Replace with an alternative if you need async Reactor-based code.


### References

1. [https://openapidoc.bitunix.com/doc/common/sign.html](https://openapidoc.bitunix.com/)
2. https://www.bitunix.com/contract-trade/BTCUSDT
3. https://github.com/BitunixOfficial/open-api/tree/main/Demo/Python
