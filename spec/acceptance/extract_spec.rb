# frozen_string_literal: true

require 'json'

class OracleAdapterFake
  def initialize(data)
    @data = data
  end

  def read(query)
    @data
  end
end

class SqsAdapterFake
  def read
    JSON.parse ({
        "Records": [
            {
                "messageId": "19dd0b57-b21e-4ac1-bd88-01bbb068cb78",
                "receiptHandle": "MessageReceiptHandle",
                "body": @data,
                "attributes": {
                    "ApproximateReceiveCount": "1",
                    "SentTimestamp": "1523232000000",
                    "SenderId": "123456789012",
                    "ApproximateFirstReceiveTimestamp": "1523232000001"
                },
                "messageAttributes": {},
                "md5OfBody": "7b270e59b47ff90a553787216d55d91d",
                "eventSource": "aws:sqs",
                "eventSourceARN": "arn:aws:sqs:eu-west-2:123456789012:MyQueue",
                "awsRegion": "eu-west-2"
            }
        ]
    }.to_json)
  end

  def write(data)
    @data = data
  end
end

describe 'Acceptance::Extract' do
  context 'when no data is supplied in the event body' do
    it 'raises an error' do
      message = JSON.parse File.open('spec/messages/sqs-empty-message.json').read

      ENV['ETL_STAGE'] = 'extract'

      expect do
        handler = Handler.new Container.new
        handler.process message: message
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end

  context "when data is supplied in the event body" do
    it 'extracts the data' do
      message = JSON.parse File.open('spec/messages/sqs-message-extract-input.json').read

      ENV['ETL_STAGE'] = 'extract'

      oracle_adapter = OracleAdapterFake.new([{'FIRST_NAME': 'Joe'}])
      sqs_adapter = SqsAdapterFake.new

      message_gateway = Gateway::MessageGateway.new(sqs_adapter)
      database_gateway = Gateway::DatabaseGateway.new(oracle_adapter)

      container = Container.new
      container.set_object(:message_gateway, message_gateway)
      container.set_object(:database_gateway, database_gateway)

      handler = Handler.new(container)

      handler.process message: message

      expected_extract_output = JSON.parse File.open('spec/messages/sqs-message-extract-output.json').read

      expect(sqs_adapter.read).to eq(expected_extract_output)
    end
  end

    context "when data is supplied in the event body" do
      it 'extracts the data' do
        message = JSON.parse File.open('spec/messages/sqs-message-extract-input.json').read
        message['Records'][0]['body']['configuration']['extract']['queries']['ASSESSOR']['multiple'] = true

        ENV['ETL_STAGE'] = 'extract'

        oracle_adapter = OracleAdapterFake.new([{'FIRST_NAME': 'Joe'}])
        sqs_adapter = SqsAdapterFake.new

        message_gateway = Gateway::MessageGateway.new(sqs_adapter)
        database_gateway = Gateway::DatabaseGateway.new(oracle_adapter)

        container = Container.new
        container.set_object(:message_gateway, message_gateway)
        container.set_object(:database_gateway, database_gateway)

        handler = Handler.new(container)

        handler.process message: message

        expected_extract_output = JSON.parse File.open('spec/messages/sqs-message-extract-output.json').read

        expect(sqs_adapter.read).to eq(expected_extract_output)
      end
  end
end
