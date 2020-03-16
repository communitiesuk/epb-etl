# frozen_string_literal: true

module Gateway
  class MessageGateway < BaseGateway
    def initialize(adapter)
      @adapter = adapter
    end

    def write(queue_url, data)
      @adapter.write(queue_url, data)
    end
  end
end
