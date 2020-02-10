# frozen_string_literal: true

class OracleAdapterFake
  def initialize(data)
    @data = data
  end

  def read(_query)
    @data
  end
end

class SqsAdapterFake
  def read
    JSON.parse ({
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
    }.to_json)
  end

  def write(data)
    @data = data
  end
end

describe 'Acceptance::Extract' do
  context 'when no data is supplied in the event body' do
    it 'raises an error' do
      message = JSON.parse File.open('spec/messages/sqs-empty-message.json').read

      ENV['ETL_STAGE'] = 'extract'

      expect do
        handler = Handler.new Container.new
        handler.process message: message
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end

  context 'when data is supplied in the event body' do
    let(:oracle_adapter) do
      OracleAdapterFake.new [
        {
          ASSESSOR_KEY: 89_030_012,
          "ACTIVE_IND": 'N',
          "ASSESSOR_ID": 'TEST000000',
          "BASE_POSTCODE_LOCATION": 'S1 1DA',
          "ADDRESS1": 'Green House',
          "ADDRESS2": '89 Street',
          "ADDRESS3": nil,
          "POST_TOWN": 'Sheffield',
          "POSTCODE": 'S1 2HE',
          "COMPANY_NAME": 'Test Ltd',
          "EMAIL": 'test@example.com',
          "COMPANY_FAX": nil,
          "TELEPHONE": '07777777777',
          "COMPANY_WEBSITE": 'www.example.com',
          "DATE_OF_BIRTH": '1980-11-01 00:00:00.000000',
          "FIRST_NAME": 'Joe',
          "NAME_PREFIX": 'Mr',
          "NAME_SUFFIX": nil,
          "SURNAME": 'Testerton',
          "DELETED_IN_UPLOAD": 123_456,
          "ORGANISATION_KEY": 444,
          "FIRST_NAME_PHONIC": 'JM',
          "SURNAME_PHONIC": 'TN',
          "ASSESSOR_LOCATION": [
            1234,
            1234,
            [
              746_745,
              523_646,
              nil
            ],
            nil,
            nil
          ],
          "MIDDLE_NAMES": 'Not Applicable',
          "DISPLAY_NAME": nil,
          "COMPANY_REG_NO": nil,
          "COMPANY_ADDR1": 'Example address',
          "COMPANY_ADDR2": 'Long Street',
          "COMPANY_ADDR3": nil,
          "COMPANY_TOWN": 'Sheffield',
          "COMPANY_POSTCODE": 'S1 1DA',
          "COMPANY_TELEPHONE": '07000 678901',
          "COMPANY_EMAIL": 'test@example.com',
          "UPI": nil
        }
      ]
    end

    it 'extracts the data' do
      message = JSON.parse File.open('spec/messages/sqs-message-extract-input.json').read

      ENV['ETL_STAGE'] = 'extract'

      sqs_adapter = SqsAdapterFake.new

      message_gateway = Gateway::MessageGateway.new(sqs_adapter)
      database_gateway = Gateway::DatabaseGateway.new(oracle_adapter)

      container = Container.new
      container.set_object(:message_gateway, message_gateway)
      container.set_object(:database_gateway, database_gateway)

      handler = Handler.new(container)
      handler.process message: message

      expected_extract_output = JSON.parse File.open('spec/messages/sqs-message-transform-input.json').read

      expect(sqs_adapter.read).to eq(expected_extract_output)
    end
  end
end
