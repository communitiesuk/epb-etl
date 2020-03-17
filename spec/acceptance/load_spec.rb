# frozen_string_literal: true

describe 'Acceptance::Load' do
  context 'when no data is supplied in the message body' do
    it 'raises an error' do
      event = JSON.parse File.open('spec/event/sqs-empty-message.json').read

      ENV['ETL_STAGE'] = 'load'

      expect do
        handler = Handler.new Container.new false
        handler.process event: event
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end

  context 'when data is supplied in the message body' do
    context 'when all required data is present' do
      it 'sends the data to the endpoint' do
        event = JSON.parse File.open('spec/event/sqs-message-load-input.json').read

        ENV['ETL_STAGE'] = 'load'

        http_stub = stub_request(:put, 'http://test-endpoint/api/schemes/1/assessors/TEST000000')
                    .to_return(body: JSON.generate(message: 'ok'), status: 200)

        logit_adapter = LogitAdapterFake.new
        log_gateway = Gateway::LogGateway.new logit_adapter
        container = Container.new false
        container.set_object(:log_gateway, log_gateway)

        handler = Handler.new container
        handler.process event: event

        expect(WebMock).to have_requested(:put, 'http://test-endpoint/api/schemes/1/assessors/TEST000000')
          .with(body: JSON.generate(
            firstName: 'Joe',
            lastName: 'Testerton',
            dateOfBirth: '1980-11-01'
          ))

        remove_request_stub(http_stub)
      end
    end
  end
end
