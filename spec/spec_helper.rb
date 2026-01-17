# frozen_string_literal: true

require "bundler/setup"
require "rspec"
require "webmock/rspec"
require "tempfile"

# Load the library under test
require "bitunix"

# Configure WebMock
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end