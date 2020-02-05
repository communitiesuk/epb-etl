# frozen_string_literal: true

require 'rspec'

require 'json'
require 'aws-sdk-sqs'

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

describe 'Acceptance::Transform' do
  context 'when no data is supplied in the event body' do
    it 'raises an error' do
      message = JSON.parse File.open('spec/messages/sqs-empty-message.json').read

      ENV['ETL_STAGE'] = 'transform'

      expect do
        handler = Handler.new Container.new
        handler.process message: message
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end

  context 'when data is supplied' do
    context 'when all required data is present' do
      it 'converts data to target hash' do
        message = JSON.parse File.open('spec/messages/sqs-message-transform-input.json').read

        ENV['ETL_STAGE'] = 'transform'

        sqs_adapter = SqsAdapterFake.new
        message_gateway = Gateway::MessageGateway.new(sqs_adapter)
        container = Container.new
        container.set_object(:message_gateway, message_gateway)
        handler = Handler.new(container)
        handler.process message: message
        expected_transform_output = JSON.parse File.open('spec/messages/sqs-message-load-input.json').read

        expect(sqs_adapter.read).to eq(expected_transform_output)
      end
    end
  end
end
