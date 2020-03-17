require 'rspec'

describe 'Acceptance::Trigger' do
  context 'when an empty trigger notification is received' do
    it 'raises an error' do
      event = JSON.parse File.open('spec/event/sns-empty-trigger-input.json').read

      ENV['ETL_STAGE'] = 'trigger'

      expect do
        handler = Handler.new Container.new false
        handler.process event: event
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end

  context 'when a trigger notification is received' do
    let(:oracle_adapter) do
      adapter = OracleAdapterFake.new OracleAdapterStub.data

      adapter.stub_query(
          'SELECT ASSESSOR_KEY FROM assessors',
          [
              {
                  "ASSESSOR_KEY": '23456789',
              }
          ]
      )

      adapter
    end

    it 'handles the event without raising an error' do
      event = JSON.parse File.open('spec/event/sns-trigger-input.json').read

      ENV['ETL_STAGE'] = 'trigger'

      sqs_adapter = SqsAdapterFake.new
      logit_adapter = LogitAdapterFake.new

      message_gateway = Gateway::MessageGateway.new(sqs_adapter)
      database_gateway = Gateway::DatabaseGateway.new(oracle_adapter)
      log_gateway = Gateway::LogGateway.new logit_adapter

      container = Container.new false
      container.set_object(:message_gateway, message_gateway)
      container.set_object(:database_gateway, database_gateway)
      container.set_object(:log_gateway, log_gateway)

      handler = Handler.new(container)
      handler.process event: event

      expected_extract_output = JSON.parse File.open('spec/event/sqs-message-extract-input.json').read

      expect(sqs_adapter.read).to eq(expected_extract_output)
    end
  end
end
