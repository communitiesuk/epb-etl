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
    it 'handles the event without raising an error' do
      event = JSON.parse File.open('spec/event/sns-trigger-input.json').read

      ENV['ETL_STAGE'] = 'trigger'

      expect do
        handler = Handler.new Container.new false
        handler.process event: event
      end.not_to raise_error
    end
  end
end
