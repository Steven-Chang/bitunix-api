require "yaml"
require "json"
require "securerandom"
require "openssl"
require "time"

require_relative "bitunix/version"
require_relative "bitunix/error_codes"

require_relative "bitunix/rest/sign"
require_relative "bitunix/rest/future_public"
require_relative "bitunix/rest/future_private"

require_relative "bitunix/ws/sign"
require_relative "bitunix/ws/future_private"

module Bitunix; end