# frozen_string_literal: true

module UseCase
  class Transform < UseCase::Base
    def execute
      response = {}
      rules = @request.body['configuration']['rules']

      rules.each do |rule|
        response[rule['to'].last] = @request.body.dig(*rule['from'])
      end

      response
    end
  end
end
