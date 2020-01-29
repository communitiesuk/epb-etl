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

      if @request.configuration.nil? || @request.configuration.empty?
        raise Errors::RequestWithoutConfiguration
      end
    end
  end
end
