# frozen_string_literal: true

module Boundary
  class BaseRequest
    attr_reader :body

    def initialize(body = nil)
      @body = body
    end
  end
end
