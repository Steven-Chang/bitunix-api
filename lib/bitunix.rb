# frozen_string_literal: true

require "yaml"
require "json"
require "securerandom"
require "openssl"
require "time"

require_relative "bitunix/version"
require_relative "bitunix/error_codes"
require_relative "bitunix/errors"
require_relative "bitunix/config"

require_relative "bitunix/rest/sign"
require_relative "bitunix/rest/json_body"
require_relative "bitunix/rest/futures"

require_relative "bitunix/ws/sign"
require_relative "bitunix/ws/auth"
require_relative "bitunix/ws/futures"

module Bitunix
  Sign = Rest::Sign
end
