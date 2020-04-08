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
          job: @request.body['job'],
          configuration: @request.body['configuration']
        }.to_json
      )

      rules = @request.body['configuration']['transform']['rules']

      rules.each do |rule|
        source_data = nil

        if rule['from'].include? '*'
          wildcard = rule['from'].index('*')
          before, after = rule['from'].each_slice(wildcard).to_a

          after.shift

          source_data = []
          before_source = @request.body.dig(*before)

          before_source.each do |value|
            source_data << value.dig(*after)
          end
        else
          source_data = @request.body.dig(*rule['from'])
        end unless rule['from'].nil?

        if rule.keys.include? 'convert'
          rule['convert'].each do |conversion|
            args = conversion['args']
            args.unshift source_data

            source_data = Helper::Transform.send conversion['type'], *args
          end
        end

        Helper::bury(response, *rule['to'], source_data)
      end

      @message_gateway.write(ENV['NEXT_SQS_URL'], response)
    end
  end
end
