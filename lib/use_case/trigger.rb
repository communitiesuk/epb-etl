# frozen_string_literal: true

module UseCase
  class Trigger < UseCase::Base
    def initialize(request, container)
      @message_gateway = container.fetch_object :message_gateway
      @database_gateway = container.fetch_object :database_gateway

      super
    end

    def execute

    end
  end
end
