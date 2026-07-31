# Changelog

## 2.2.0

### Added
- Futures public WebSocket: `Bitunix::WS::Futures::Public` (connects to `websocket.public_uri`, no login)
- Futures private REST `place_order`: stop-loss params (`sl_price`, `sl_stop_type`, `sl_order_type`, `sl_order_price`)

### Changed
- Shared futures WebSocket connection logic extracted to `Bitunix::WS::Futures::Base`

## 2.1.0

### Added
- Futures private REST: `get_leverage_and_margin_mode`

## 2.0.0

Unified REST client and spot support. Existing `Bitunix::Rest::Futures::*` callers keep working.

### Added
- `Bitunix::Client` with `futures` and `spot` namespaces
- Spot public REST: `Bitunix::Rest::Spot::Public#query_token_data`
- Config: `futures_uri_prefix`, `spot_uri_prefix`

### Changed
- Recommended entry point is `Bitunix::Client` instead of constructing futures clients directly
- Config `uri_prefix` is now a legacy alias for `futures_uri_prefix` (same default: `https://fapi.bitunix.com`)

### Compatibility
- Apps on `0.x` are unaffected until they intentionally upgrade to `2.x`
- Direct use of `Bitunix::Rest::Futures::Public` / `Private` remains supported in 2.0.0

## 0.1.0

Initial futures REST + private WebSocket client.
