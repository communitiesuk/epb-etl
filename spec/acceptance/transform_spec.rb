# frozen_string_literal: true

require 'rspec'

require 'json'
require 'aws-sdk-sqs'

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
        client = Aws::SQS::Client.new(region: 'eu-west-2', stub_responses: true)
        data = [ body: {
            'firstName' => 'Joe',
            'lastName' => 'Testerton',
            'dateOfBirth' => '1980-11-01 00:00:00.000000',
            'schemeId' => 444,
            'schemeAssessorId' => 'TEST000000'
        }.to_json]


        queue_url = 'https://sqs.eu-west-2.amazonaws.com/012345678901/test'

        client.stub_responses(:receive_message, messages:
            data
                              )

        response  = client.receive_message({
                                     queue_url: queue_url,
                                     attribute_names: ['All'],
                                 })

        parsed_json = JSON.parse(response.messages.first.body)

        expect(parsed_json).to include({
                                          'firstName' => 'Joe',
                                          'lastName' => 'Testerton',
                                          'dateOfBirth' => '1980-11-01 00:00:00.000000',
                                          'schemeId' => 444,
                                          'schemeAssessorId' => 'TEST000000'
                                      })

      end
    end
  end
end
