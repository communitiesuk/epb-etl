# frozen_string_literal: true

module UseCase
  class Load < UseCase::Base
    def execute
      method = @request.body['endpoint']['method']

      uri = URI.parse(@request.body['endpoint']['uri'])
      body = JSON.generate(@request.body['data'])

      req = Net::HTTP.const_get(method.capitalize).new(uri.path)

      req['Content-Length'] = body.length

      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request req, body
      end
    end
  end
end
