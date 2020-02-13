# frozen_string_literal: true

class SqsAdapterFake
  def initialize(data = nil)
    @data = data
  end

  def read
    JSON.parse(
      {
        "Records": [
          {
            "messageId": '19dd0b57-b21e-4ac1-bd88-01bbb068cb78',
            "receiptHandle": 'MessageReceiptHandle',
            "body": @data,
            "attributes": {
              "ApproximateReceiveCount": '1',
              "SentTimestamp": '1523232000000',
              "SenderId": '123456789012',
              "ApproximateFirstReceiveTimestamp": '1523232000001'
            },
            "messageAttributes": {},
            "md5OfBody": '7b270e59b47ff90a553787216d55d91d',
            "eventSource": 'aws:sqs',
            "eventSourceARN": 'arn:aws:sqs:eu-west-2:123456789012:MyQueue',
            "awsRegion": 'eu-west-2'
          }
        ]
      }.to_json
    )
  end

  def write(_queue_url, data)
    @data = data
  end
end
