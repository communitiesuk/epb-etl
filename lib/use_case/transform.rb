# frozen_string_literal: true

module UseCase
  class Transform
    def initialize(request)
      @request = request
    end

    def execute
      if @request.body.nil? || @request.body.empty?
        raise Errors::Transform::RequestInvalid.new, 'Empty event body'
      end
    end
  end
end
