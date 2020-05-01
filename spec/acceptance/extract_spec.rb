# frozen_string_literal: true

describe 'Acceptance::Extract' do
  context 'when no data is supplied in the message body' do
    it 'raises an error' do
      event = JSON.parse File.open('spec/event/sqs-empty-message.json').read

      ENV['ETL_STAGE'] = 'extract'

      expect do
        handler = Handler.new Container.new false
        handler.process event: event
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end

  context 'when invalid data is supplied in the message body' do
    let(:oracle_adapter) { OracleAdapterFake.new OracleAdapterStub.data }

    it 'handles the event by logging the error' do
      event = JSON.parse File.open('spec/event/sqs-message-invalid.json').read

      ENV['ETL_STAGE'] = 'extract'

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

      expect(logit_adapter.data).to include JSON.generate(
                {
                  stage: 'extract',
                  event: 'fail',
                  data: {
                    error: 'undefined method `each\' for nil:NilClass',
                    job: { "ASSESSOR": %w[23456789] }
                  }
                }
              )
    end
  end

  context 'when data is supplied in the message body' do
    let(:oracle_adapter) do
      adapter = OracleAdapterFake.new OracleAdapterStub.data

      adapter.stub_query(
        "SELECT POSTCODE FROM assessor_coverage WHERE ASSESSOR_KEY = '23456789'",
        [{ "POSTCODE": 'SW2A 3AA' }, { "POSTCODE": 'SW3A 4AA' }]
      )

      adapter.stub_query(
        "SELECT TYPE, STATUS FROM assessor_qualifications WHERE ASSESSOR_KEY = '23456789'",
        [
          { "TYPE": 'Level 1', "STATUS": 'ACTIVE' },
          { "TYPE": 'Level 2', "STATUS": 'INACTIVE' }
        ]
      )

      adapter
    end

    it 'extracts the data' do
      event =
        JSON.parse File.open('spec/event/sqs-message-extract-input.json').read

      ENV['ETL_STAGE'] = 'extract'

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

      expected_extract_output =
        JSON.parse File.open('spec/event/sqs-message-transform-input.json').read

      expect(sqs_adapter.read).to eq(expected_extract_output)
    end
  end
end
