# frozen_string_literal: true

module Boundary
  class BaseRequest
    attr_reader :body, :configuration

    def initialize(body = nil, configuration = nil)
      @body = body
      @configuration = configuration
    end
  end
end
