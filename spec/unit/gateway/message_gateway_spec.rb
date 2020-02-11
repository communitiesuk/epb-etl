# frozen_string_literal: true

describe Gateway::MessageGateway do
  context 'when reading from the adapter' do
    it 'modifies the message' do
      sqs_adapter = SqsAdapterFake.new
      message_gateway = Gateway::MessageGateway.new(sqs_adapter)
      response = message_gateway.write('Testy testington')

      expect(response).to eq('Testy testington')
    end
  end
end
