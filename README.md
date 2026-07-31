# bitunix-api

Ruby client for the [Bitunix Open API](https://openapidoc.bitunix.com/) — **v2.3.0**.

It provides:
- Config: load credentials and endpoints from YAML (`Bitunix::Config`)
- Unified REST client: `Bitunix::Client` with `futures` and `spot` namespaces
- REST clients: `Bitunix::Rest::Futures::*` and `Bitunix::Rest::Spot::*` (also usable directly)
- WebSocket clients: `Bitunix::WS::Futures::Public` and `Bitunix::WS::Futures::Private` (EventMachine-backed)
- Signing utilities: `Bitunix::Sign`

Requires Ruby >= 3.2.1.

## Installation

**Version 2** (unified client + spot):

```ruby
gem "bitunix-api", git: "https://github.com/Steven-Chang/bitunix-api", tag: "v2.3.0"
```

**Stay on 0.x** (futures-only API, no unified client):

```ruby
gem "bitunix-api", git: "https://github.com/Steven-Chang/bitunix-api", tag: "v0.1.0"
```

Or for local development:

```bash
bundle install

# optional: build the gem
gem build bitunix-api.gemspec
```

## Upgrading from 0.x to 2.x

`2.0.0` is additive for existing futures usage. You do **not** need to rewrite apps that already use `Bitunix::Rest::Futures::*`.

Optional migration to the unified client:

```ruby
# 0.x
public_client = Bitunix::Rest::Futures::Public.new(config)
private_client = Bitunix::Rest::Futures::Private.new(config)

# 2.x (recommended)
client = Bitunix::Client.new(config)
client.futures.get_tickers("BTCUSDT")
client.futures.get_account
client.spot.query_token_data
```

Config can keep `http.uri_prefix` (still means futures). Prefer the explicit keys when using both markets:

```yaml
http:
  futures_uri_prefix: https://fapi.bitunix.com
  spot_uri_prefix: https://openapi.bitunix.com
```

See [CHANGELOG.md](CHANGELOG.md) for details.

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
  futures_uri_prefix: https://fapi.bitunix.com
  spot_uri_prefix: https://openapi.bitunix.com
  # uri_prefix is still supported as a legacy alias for futures_uri_prefix
```

## Usage

```ruby
require "bitunix-api"

config = Bitunix::Config.new("config.yaml")
client = Bitunix::Client.new(config)

# Futures REST (public + private on the same accessor)
tickers = client.futures.get_tickers("BTCUSDT,ETHUSDT")
account = client.futures.get_account

# Spot REST
tokens = client.spot.query_token_data

# TP/SL
client.futures.tpsl.cancel_order("BTCUSDT", "12")
client.futures.tpsl.get_history_orders(symbol: "BTCUSDT")
client.futures.tpsl.get_pending_orders(symbol: "BTCUSDT")
client.futures.tpsl.place_order("BTCUSDT", "111", tp_price: "12", sl_price: "9", tp_qty: "1", sl_qty: "1")
client.futures.tpsl.position_place_order("BTCUSDT", "111", tp_price: "12", sl_price: "9")
client.futures.tpsl.modify_order("123", tp_price: "12", sl_price: "9")
client.futures.tpsl.position_modify_order("BTCUSDT", "11", tp_price: "12", sl_price: "9")

# Or construct market clients directly (config or api_key + secret_key)
public_client = Bitunix::Rest::Futures::Public.new(config)
private_client = Bitunix::Rest::Futures::Private.new(config)
# private_client = Bitunix::Rest::Futures::Private.new("YOUR_API_KEY", "YOUR_SECRET_KEY")

# Public WebSocket (market data — no login)
public_ws = Bitunix::WS::Futures::Public.new(config)
public_ws.on_message { |msg| puts msg }
public_ws.connect
public_ws.subscribe([
  { "symbol" => "BTCUSDT", "ch" => "market_kline_1min" },
  { "symbol" => "BTCUSDT", "ch" => "depth_books" }
])

# Private WebSocket (account streams — signed login on connect)
private_ws = Bitunix::WS::Futures::Private.new(config)
private_ws.on_message { |msg| puts msg }
private_ws.connect
private_ws.subscribe([{ "ch" => "balance" }, { "ch" => "position" }])
```

### Futures public REST helpers

Available via `client.futures` / `Bitunix::Rest::Futures::Public`:

- `get_tickers`
- `get_trading_pairs`
- `get_depth`
- `get_kline`
- `get_batch_funding_rate`

### Futures private REST helpers

Available via `client.futures` / `Bitunix::Rest::Futures::Private`:

- Account: `get_account`, `get_leverage_and_margin_mode`, `change_leverage`, `change_margin_mode`, `change_position_mode`, `adjust_position_margin`
- Orders: `place_order`, `batch_order`, `cancel_orders`, `cancel_all_orders`, `get_pending_orders`, `get_history_orders`
- Positions / trades: `get_pending_positions`, `get_history_positions`, `get_history_trades`
- TP/SL: `tpsl.cancel_order`, `tpsl.get_history_orders`, `tpsl.get_pending_orders`, `tpsl.place_order`, `tpsl.position_place_order`, `tpsl.modify_order`, `tpsl.position_modify_order`

### Spot public REST helpers

Available via `client.spot` / `Bitunix::Rest::Spot::Public`:

- `query_token_data`

## Development

```bash
bundle exec rspec
bundle exec rubocop
```

## Notes

- This is a thin client around Bitunix futures and spot endpoints. Harden for production as needed (timeouts, retries, logging).
- Error codes live in `lib/bitunix/error_codes.rb`.
- WebSocket uses EventMachine via `websocket-eventmachine-client` (auto-starts a reactor thread when needed).
- A successful REST response does not always mean the operation succeeded. For order-related actions, use WebSocket push messages to confirm the final state.

## References

1. [Bitunix signing docs](https://openapidoc.bitunix.com/doc/common/sign.html)
2. [Bitunix contract trade](https://www.bitunix.com/contract-trade/BTCUSDT)
3. [Official open-api demos (Python)](https://github.com/BitunixOfficial/open-api/tree/main/Demo/Python)
