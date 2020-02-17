# frozen_string_literal: true

class Container
  def initialize(bootstrap = true)
    @objects = {}

    if bootstrap
      sqs_client = Aws::SQS::Client.new
      sqs_adapter = Adapter::SqsAdapter.new sqs_client
      message_gateway = Gateway::MessageGateway.new(sqs_adapter: sqs_adapter)

      @objects[:message_gateway] = message_gateway
    end
  end

  def fetch_object(key)
    @objects[key]
  end

  def set_object(key, object)
    @objects[key] = object
  end
end
