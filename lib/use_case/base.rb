# frozen_string_literal: true

module UseCase
  class Base
    def initialize(request)
      @request = request

      validate
    end

    private

    def validate
      if @request.body.nil? || @request.body.empty?
        raise Errors::RequestWithoutBody
      end
    end
  end
end
