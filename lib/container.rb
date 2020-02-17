# frozen_string_literal: true

class Container
  def initialize(bootstrap = true)
    @objects = {}

    if bootstrap
      sqs_client = Aws::SQS::Client.new
      oracle_client = OCI8.new ENV['ORACLE_CONNECT_STRING']

      sqs_adapter = Adapter::SqsAdapter.new sqs_client
      oracle_adapter = Adapter::OracleAdapter.new oracle_client

      message_gateway = Gateway::MessageGateway.new(sqs_adapter: sqs_adapter)
      database_gateway = Gateway::DatabaseGateway.new(oracle_adapter: oracle_adapter)

      @objects[:message_gateway] = message_gateway
      @objects[:database_gateway] = database_gateway
    end
  end

  def fetch_object(key)
    @objects[key]
  end

  def set_object(key, object)
    @objects[key] = object
  end
end
