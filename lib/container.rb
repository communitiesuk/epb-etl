# frozen_string_literal: true

require "aws-sdk-sqs"

class Container
  def initialize(bootstrap = true)
    @objects = {}

    if bootstrap
      sqs_client = Aws::SQS::Client.new

      sqs_adapter = Adapter::SqsAdapter.new sqs_client
      oracle_adapter = Adapter::OracleAdapter.new
      logit_adapter = Adapter::LogitAdapter.new

      message_gateway = Gateway::MessageGateway.new(sqs_adapter)
      database_gateway = Gateway::DatabaseGateway.new(oracle_adapter)
      log_gateway = Gateway::LogGateway.new(logit_adapter)

      @objects[:message_gateway] = message_gateway
      @objects[:database_gateway] = database_gateway
      @objects[:log_gateway] = log_gateway
    end
  end

  def fetch_object(key)
    @objects[key]
  end

  def set_object(key, object)
    @objects[key] = object
  end
end
