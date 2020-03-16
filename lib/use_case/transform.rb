# frozen_string_literal: true

module UseCase
  class Transform < UseCase::Base
    def initialize(request, container)
      @message_gateway = container.fetch_object :message_gateway

      super
    end

    def execute
      response = JSON.parse(
        {
          configuration: @request.body['configuration']
        }.to_json
      )

      rules = @request.body['configuration']['transform']['rules']

      rules.each do |rule|
        source_data = @request.body.dig(*rule['from'])

        if rule.keys.include? 'convert'
          args = rule['convert']['args']
          args.unshift source_data

          source_data = Helper::Transform.send rule['convert']['type'], *args
        end

        Helper::bury(response, *rule['to'], source_data)
      end

      @message_gateway.write(ENV['NEXT_SQS_URL'], response)
    end
  end
end
