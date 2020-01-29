require 'rspec'

require 'json'

describe 'Acceptance::Transform' do
  context 'when no data is supplied in the event body' do
    it 'raises an error' do
      event = JSON.parse File.open('spec/events/sqs-empty-event.json').read

      request = Boundary::TransformRequest.new event['Records'][0]['body']

      expect do
        UseCase::Transform.new request
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end

  context 'when no configuration is supplied to the use case' do
    it 'raises an error' do
      event = JSON.parse File.open('spec/events/sqs-event.json').read
      configuration = {}

      request = Boundary::TransformRequest.new event['Records'][0]['body'],
                                               configuration

      expect do
        UseCase::Transform.new request
      end.to raise_error instance_of Errors::RequestWithoutConfiguration
    end
  end
end
