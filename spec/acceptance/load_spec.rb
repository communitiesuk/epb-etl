require 'rspec'

require 'json'

describe 'Acceptance::Load' do
  context 'when no data is supplied in the event body' do
    it 'raises an error' do
      message = JSON.parse File.open('spec/messages/sqs-empty-message.json').read

      ENV['ETL_STAGE'] = 'load'

      expect do
        handler = Handler.new
        handler.process message: message
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end
end
