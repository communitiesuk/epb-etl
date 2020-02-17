# frozen_string_literal: true

require 'epb_auth_tools'

module UseCase
  class Load < UseCase::Base
    def execute
      method = @request.body['configuration']['load']['endpoint']['method']
      uri = URI.parse(@request.body['configuration']['load']['endpoint']['uri'])
      body = JSON.generate(@request.body['data'])
      req = Net::HTTP.const_get(method.capitalize).new(uri.path)
      req['Content-Length'] = body.length

      http_client = Auth::HttpClient.new ENV['EPB_AUTH_CLIENT_ID'],
                                         ENV['EPB_AUTH_CLIENT_SECRET'],
                                         ENV['EPB_AUTH_SERVER'],
                                         ENV['EPB_API_URL'],
                                         OAuth2::Client

      http_client.request method, uri.path, body: body, headers: {
        'Content-Length' => body.length.to_s,
        'Content-Type' => 'application/json'
      }
    end
  end
end
