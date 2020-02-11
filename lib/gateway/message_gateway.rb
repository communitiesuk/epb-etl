# frozen_string_literal: true

module Gateway
  class MessageGateway
    def initialize(sqs_adapter)
      @sqs_adapter = sqs_adapter
    end

    def read(body)
      body
    end

    def write(data)
      @sqs_adapter.write(data)
    end
  end
end
