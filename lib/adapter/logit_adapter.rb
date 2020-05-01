# frozen_string_literal: true

require 'net/http'

module Adapter
  class LogitAdapter < Adapter::BaseAdapter
    def write(stage, event, data)
      log_data = JSON.generate({ stage: stage, event: event, data: data })

      uri = URI.parse 'https://api.logit.io/v2'

      net = Net::HTTP.new uri.hostname, uri.port
      net.use_ssl = true
      net.verify_mode = OpenSSL::SSL::VERIFY_PEER

      request = Net::HTTP::Post.new uri.request_uri
      request['ApiKey'] = ENV['LOGIT_API_KEY']
      request['Content-Type'] = 'application/json'
      request['LogType'] = 'default'

      net.request(request, log_data)
    end
  end
end
