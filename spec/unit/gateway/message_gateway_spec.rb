# frozen_string_literal: true

describe Gateway::MessageGateway do
  context 'when reading from the adapter' do
    it 'modifies the message' do
      sqs_adapter = SqsAdapterFake.new
      message_gateway = Gateway::MessageGateway.new(sqs_adapter)
      queue_url = 'https://sqs.eu-west-2.amazonaws.com/1234567890/test'
      response = message_gateway.write(queue_url, 'something')

      expect(response).to eq('something')
    end
  end
end
