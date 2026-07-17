# frozen_string_literal: true

module Bitunix
  class Error < StandardError; end

  class HttpError < Error
    attr_reader :status, :body

    def initialize(status, body = nil)
      @status = status
      @body = body
      super("HTTP Error: #{status}")
    end
  end

  # Raised when Bitunix returns a non-zero business code.
  # The exchange often only sends { code, msg, data } — use #code / #msg / #data
  # for the raw payload, and #message for a human-readable summary.
  class ApiError < Error
    attr_reader :code, :msg, :data, :response

    def initialize(response)
      @response = response
      @code = response["code"]
      @msg = response["msg"]
      @data = response["data"]
      super(format_message)
    end

    private

    def format_message
      mapped = ErrorCode.get_by_code(code)
      parts = ["Bitunix API error #{code}"]
      parts << mapped if mapped && mapped != msg
      parts << msg if msg && !msg.to_s.empty?
      parts << "data=#{data.inspect}" unless data.nil?
      parts.join(": ")
    end
  end
end
