# frozen_string_literal: true

module Boundary
  class TransformRequest
    attr_reader :body

    def initialize(body = nil)
      @body = body
    end
  end
end
