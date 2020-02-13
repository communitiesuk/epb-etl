# frozen_string_literal: true

module Gateway
  class MessageGateway
    def initialize(sqs_adapter)
      @sqs_adapter = sqs_adapter
    end

    def write(queue_url, data)
      @sqs_adapter.write(queue_url, data)
    end
  end
end
