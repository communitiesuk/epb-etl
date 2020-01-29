require 'rspec'

require 'json'

describe 'Acceptance::Transform' do
  context 'when no data is supplied in the event body' do
    it 'raises an error' do
      event = JSON.parse File.open('spec/events/empty-event.json').read

      request = Boundary::TransformRequest.new event['body']

      transform = UseCase::Transform.new request

      expect do
        transform.execute
      end.to raise_error instance_of Errors::Transform::RequestInvalid
    end
  end
end
