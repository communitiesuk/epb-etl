# frozen_string_literal: true

describe Gateway::MessageGateway do
  context 'when reading from the adapter' do
    it 'returns the message' do
      sqs_adapter = SqsAdapterFake.new

      message_gateway = Gateway::MessageGateway.new(sqs_adapter)
      response = message_gateway.read

      expect(response).to eq(
        'Records' => [
          {
            'attributes' => {
              'ApproximateFirstReceiveTimestamp' => '1523232000001',
              'ApproximateReceiveCount' => '1',
              'SenderId' => '123456789012',
              'SentTimestamp' => '1523232000000'
            },
            'awsRegion' => 'eu-west-2',
            'body' => nil,
            'eventSource' => 'aws:sqs',
            'eventSourceARN' => 'arn:aws:sqs:eu-west-2:123456789012:MyQueue',
            'md5OfBody' => '7b270e59b47ff90a553787216d55d91d',
            'messageAttributes' => {},
            'messageId' => '19dd0b57-b21e-4ac1-bd88-01bbb068cb78',
            'receiptHandle' => 'MessageReceiptHandle'
          }
        ]
      )
    end

    it 'modifies the message' do
      sqs_adapter = SqsAdapterFake.new

      message_gateway = Gateway::MessageGateway.new(sqs_adapter)
      response = message_gateway.write('Testy testington')

      expect(response).to eq('Testy testington')
    end
  end
end
