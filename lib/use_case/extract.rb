# frozen_string_literal: true

module UseCase
  class Extract
    def initialize(request)
      @request = request
    end

    def execute
      validate
    end

    private

    def validate
      if @request.body.nil? || @request.body.empty?
        raise Errors::RequestWithoutBody
      end

      if @request.configuration.nil? || @request.configuration.empty?
        raise Errors::RequestWithoutConfiguration
      end
    end
  end
end
