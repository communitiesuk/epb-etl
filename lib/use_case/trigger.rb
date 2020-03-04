# frozen_string_literal: true

module UseCase
  class Trigger < UseCase::Base
    def initialize(request, container)
      @message_gateway = container.fetch_object :message_gateway
      @database_gateway = container.fetch_object :database_gateway

      super
    end

    def execute
      scanners = @request.body['configuration']['trigger']['scanners']

      scanners.each_pair do |name, config|
        @database_gateway.read(config['scan'])
      end
    end
  end
end
