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
          job: @request.body['job'],
          configuration: @request.body['configuration'],
          data: {
          }
        }.to_json
      )

      queries = @request.body['configuration']['extract']['queries']

      queries.each do |key, query|
        response['data'][key] = @database_gateway.read(query)
      end

      @message_gateway.write(ENV['NEXT_SQS_URL'], response)
    end
  end
end
