# frozen_string_literal: true

describe Adapter::SqsAdapter do
  context "when sending a message" do
    let(:sqs_client) do
      Aws::SQS::Client.new(region: ENV["AWS_SQS_REGION"], stub_responses: true)
    end
    let(:sqs_adapter) { described_class.new(sqs_client) }
    let(:queue_url) { "https://sqs.eu-west-2.amazonaws.com/1234567890/test" }

    context "when the queue URL is invalid" do
      it "raises an argument error" do
        expect {
          sqs_adapter.write("", "body")
        }.to raise_error an_instance_of Errors::SqsClientHasInvalidQueueUrl
      end
    end

    context "when the body of the message is invalid" do
      it "raises an argument error" do
        expect {
          sqs_adapter.write(queue_url, nil)
        }.to raise_error an_instance_of Errors::SqsClientWithoutMessageBody
      end
    end

    context "when the queue URL and message body is valid" do
      it "successfully sends a message" do
        response = sqs_adapter.write(queue_url, "body")

        expect(response.successful?).to be_truthy
      end
    end
  end
end
