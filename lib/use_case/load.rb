# frozen_string_literal: true

require 'epb_auth_tools'
require 'erb'

module UseCase

  class Load < UseCase::Base
    def execute
      body = JSON.generate(@request.body['data'])
      params, method, uri = @request.body['configuration']['load']['endpoint']
                                .values_at('params', 'method', 'uri')

      begin
        uri = params.nil? ?
                URI.parse(uri) :
                URI.parse(ERB.new(uri).result_with_hash(params))
      rescue NameError => e
        raise Errors::RequestWithInvalidParams, e.message, e.backtrace
      end

      http_client = Auth::HttpClient.new ENV['EPB_AUTH_CLIENT_ID'],
                                         ENV['EPB_AUTH_CLIENT_SECRET'],
                                         ENV['EPB_AUTH_SERVER'],
                                         ENV['EPB_API_URL'],
                                         OAuth2::Client

      response = http_client.request method, uri.path, body: body, headers: {
        'Content-Length' => body.length.to_s,
        'Content-Type' => 'application/json'
      }

      unless response.status > 199 && response.status < 300
        response_body = JSON.parse(response.body)
        raise Errors::LoadHttpErrorResponse.new "Got a #{response.status} (#{response_body.to_json}) on #{method} #{uri.path}"
      end

      response
    end
  end
end
