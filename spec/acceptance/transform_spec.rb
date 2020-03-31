# frozen_string_literal: true

describe 'Acceptance::Transform' do
  context 'when all required data is present' do
    it 'converts data to target hash' do
      event = JSON.parse File.open('spec/event/sqs-message-transform-input.json').read

      ENV['ETL_STAGE'] = 'transform'

      sqs_adapter = SqsAdapterFake.new
      logit_adapter = LogitAdapterFake.new

      message_gateway = Gateway::MessageGateway.new(sqs_adapter)
      log_gateway = Gateway::LogGateway.new logit_adapter

      container = Container.new false
      container.set_object(:message_gateway, message_gateway)
      container.set_object(:log_gateway, log_gateway)

      handler = Handler.new(container)
      handler.process event: event

      expected_transform_output = JSON.parse File.open('spec/event/sqs-message-load-input.json').read

      expect(sqs_adapter.read).to eq(expected_transform_output)
    end
  end

  context 'when invalid data is supplied in the message body' do
    context 'when the data present is invalid' do
      it 'handles the event by logging the error' do
        event = JSON.parse File.open('spec/event/sqs-message-invalid.json').read

        ENV['ETL_STAGE'] = 'transform'

        sqs_adapter = SqsAdapterFake.new
        logit_adapter = LogitAdapterFake.new

        message_gateway = Gateway::MessageGateway.new(sqs_adapter)
        log_gateway = Gateway::LogGateway.new logit_adapter

        container = Container.new false
        container.set_object(:message_gateway, message_gateway)
        container.set_object(:log_gateway, log_gateway)

        handler = Handler.new(container)
        handler.process event: event


        expect(logit_adapter.data).to include JSON.generate({
                                                                stage: 'transform',
                                                                event: 'fail',
                                                                data: {
                                                                    error: 'undefined method `unshift\' for nil:NilClass',
                                                                    job: {
                                                                        "ASSESSOR": ["23456789"]
                                                                    }
                                                                },
                                                            })
      end
    end
  end

  context 'when no data is supplied in the message body' do
    it 'raises an error' do
      event = JSON.parse File.open('spec/event/sqs-empty-message.json').read

      ENV['ETL_STAGE'] = 'transform'

      expect do
        handler = Handler.new Container.new false
        handler.process event: event
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end
end
