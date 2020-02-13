# frozen_string_literal: true

module UseCase
  class Extract < UseCase::Base
    def initialize(request, container)
      @message_gateway = container.fetch_object :message_gateway
      @database_gateway = container.fetch_object :database_gateway

      super
    end

    def execute
      response = JSON.parse(
        {
          configuration: @request.body['configuration'],
          data: {
          }
        }.to_json
      )

      queue_url = @request.body['configuration']['transform']['queue_url']
      queries = @request.body['configuration']['extract']['queries']

      queries.each do |key, query|
        response['data'][key] = @database_gateway.read(query)
      end

      @message_gateway.write(queue_url, response)
    end
  end
end
