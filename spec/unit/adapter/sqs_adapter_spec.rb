# frozen_string_literal: true

describe Adapter::SqsAdapter do
  context 'when sending a message' do
    let(:queue_url){"https://sqs.eu-west-2.amazonaws.com/1234567890/test"}

    context 'when the queue URL is invalid' do
      it 'raises an argument error' do
        sqs_client = Aws::SQS::Client.new(region: ENV['AWS_SQS_REGION'], stub_responses: true)
        sqs_adapter = Adapter::SqsAdapter.new(sqs_client)

        expect do
          sqs_adapter.write('', 'body')
        end.to raise_error an_instance_of ArgumentError
      end
    end

    context 'when the body of the message is invalid' do
      it 'raises an argument error' do
        sqs_client = Aws::SQS::Client.new(region: ENV['AWS_SQS_REGION'], stub_responses: true)
        sqs_adapter = Adapter::SqsAdapter.new(sqs_client)

        expect do
          sqs_adapter.write(queue_url, nil)
        end.to raise_error an_instance_of ArgumentError
      end
    end

    context 'when the queue URL and message body is valid' do
      it 'successfully sends a message' do
        sqs_client = Aws::SQS::Client.new(region: ENV['AWS_SQS_REGION'], stub_responses: true)
        sqs_adapter = Adapter::SqsAdapter.new(sqs_client)

        response = sqs_adapter.write(queue_url, 'body')
        expect(response.successful?).to be_truthy
      end
    end
  end
end
