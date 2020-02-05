class Container
  def initialize
    sqs_adapter = Adapter::SqsAdapter.new
    message_gateway = Gateway::MessageGateway.new(sqs_adapter: sqs_adapter)

    @objects = {
        message_gateway: message_gateway
    }
  end

  def fetch_object(key)
    @objects[key]
  end

  def set_object(key, object)
    @objects[key] = object
  end
end
