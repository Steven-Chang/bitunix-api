# bitunix-api

Ruby client for the [Bitunix Open API](https://openapidoc.bitunix.com/), focused on futures REST and private WebSocket.

It provides:
- Config: load credentials and endpoints from YAML (`Bitunix::Config`)
- REST clients: `Bitunix::Rest::Futures::Public` and `Bitunix::Rest::Futures::Private`
- WebSocket client: `Bitunix::WS::Futures::Private` (EventMachine-backed)
- Signing utilities: `Bitunix::Sign`

Requires Ruby >= 3.2.1.

## Installation

Add to your Gemfile:

```ruby
gem "bitunix-api", git: "https://github.com/Steven-Chang/bitunix-api"
```

Or for local development:

```bash
bundle install

# optional: build the gem
gem build bitunix-api.gemspec
```

## Configuration

Create a `config.yaml`:

```yaml
credentials:
  api_key: YOUR_API_KEY
  secret_key: YOUR_SECRET_KEY
websocket:
  public_uri: wss://fapi.bitunix.com/public/
  private_uri: wss://fapi.bitunix.com/private/
  reconnect_interval: 5
http:
  uri_prefix: https://fapi.bitunix.com
```

## Usage

```ruby
require "bitunix-api"

config = Bitunix::Config.new("config.yaml")

# Public REST
public_client = Bitunix::Rest::Futures::Public.new(config)
tickers = public_client.get_tickers("BTCUSDT,ETHUSDT")

# Private REST (config or api_key + secret_key)
private_client = Bitunix::Rest::Futures::Private.new(config)
account = private_client.get_account
# private_client = Bitunix::Rest::Futures::Private.new("YOUR_API_KEY", "YOUR_SECRET_KEY")

# TP/SL
private_client.tpsl.cancel_order("BTCUSDT", "12")

# Private WebSocket
ws = Bitunix::WS::Futures::Private.new(config)
ws.on_message { |msg| puts msg }
ws.connect
ws.subscribe([{ "ch" => "balance" }, { "ch" => "position" }])
```

### Public REST helpers

Available via `Bitunix::Rest::Futures::Public`:

- `get_tickers`
- `get_trading_pairs`
- `get_depth`
- `get_kline`
- `get_batch_funding_rate`

### Private REST helpers

Available via `Bitunix::Rest::Futures::Private`:

- Account: `get_account`, `change_leverage`, `change_margin_mode`, `change_position_mode`, `adjust_position_margin`
- Orders: `place_order`, `batch_order`, `cancel_orders`, `cancel_all_orders`, `get_pending_orders`, `get_history_orders`
- Positions / trades: `get_pending_positions`, `get_history_positions`, `get_history_trades`
- TP/SL: `tpsl.cancel_order`

## Development

```bash
bundle exec rspec
bundle exec rubocop
```

## Notes

- This is a thin client around Bitunix futures endpoints. Harden for production as needed (timeouts, retries, logging).
- Error codes live in `lib/bitunix/error_codes.rb`.
- WebSocket uses EventMachine via `websocket-eventmachine-client` (auto-starts a reactor thread when needed).
- A successful REST response does not always mean the operation succeeded. For order-related actions, use WebSocket push messages to confirm the final state.

## References

1. [Bitunix signing docs](https://openapidoc.bitunix.com/doc/common/sign.html)
2. [Bitunix contract trade](https://www.bitunix.com/contract-trade/BTCUSDT)
3. [Official open-api demos (Python)](https://github.com/BitunixOfficial/open-api/tree/main/Demo/Python)
