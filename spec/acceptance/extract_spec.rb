# frozen_string_literal: true

require 'json'

class OracleAdapterFake

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

      oracle_adapter = OracleAdapterFake.new
      sqs_adapter = SqsAdapterFake.new

      message_gateway = Gateway::MessageGateway.new(sqs_adapter)
      database_gateway = Gateway::DatabaseGateway.new(oracle_adapter)

      container = Container.new
      container.set_object(:message_gateway, message_gateway)
      container.set_object(:database_gateway, database_gateway)

      handler = Handler.new(container)
      handler.process message: message

      expected_extract_output = JSON.parse File.open('spec/messages/sqs-message-transform-input.json').read

      expect(sqs_adapter.read).to eq(expected_extract_output)
    end
  end
end
