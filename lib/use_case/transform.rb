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

      queue_url = @request.body['configuration']['load']['queue_url']
      rules = @request.body['configuration']['transform']['rules']

      rules.each do |rule|
        if rule['to'].include? 'dateOfBirth'
          @request.body['data']['ASSESSOR']["DATE_OF_BIRTH"] = convert_date_format(rule)
        end

        bury(response, *rule['to'], @request.body.dig(*rule['from']))
      end

      @message_gateway.write(queue_url, response)
    end

    private

    def convert_date_format(rule)
      data_of_birth = @request.body['data']['ASSESSOR']["DATE_OF_BIRTH"]
      date_format = rule['convert']['format']
      Date.parse(data_of_birth).strftime(date_format)
    end

    def bury(hash, *args)
      if args.count < 2
        raise ArgumentError, '2 or more arguments required'
      elsif args.count == 2
        hash[args[0]] = args[1]
      else
        arg = args.shift
        hash[arg] = {} unless hash[arg]
        bury(hash[arg], *args) unless args.empty?
      end

      hash
    end
  end
end
