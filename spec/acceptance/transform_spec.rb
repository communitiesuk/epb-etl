# frozen_string_literal: true

require 'rspec'

require 'json'

describe 'Acceptance::Transform' do
  context 'when no data is supplied in the event body' do
    it 'raises an error' do
      message = JSON.parse File.open('spec/messages/sqs-empty-message.json').read

      ENV['ETL_STAGE'] = 'transform'

      expect do
        handler = Handler.new
        handler.process message: message
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end

  context 'when data is supplied' do
    context 'when all required data is present' do
      it 'converts data to target hash' do
        message = JSON.parse File.open('spec/messages/sqs-message-transform-input.json').read

        ENV['ETL_STAGE'] = 'transform'

        handler = Handler.new
        response = handler.process message: message

        expect(response.first).to include(
          'body' => {
            'firstName' => 'Joe',
            'lastName' => 'Testerton',
            'dateOfBirth' => '1980-11-01 00:00:00.000000',
            'schemeId' => 142,
            'schemeAssessorId' => 'TEST000000'
          }
        )
      end
    end
  end
end
