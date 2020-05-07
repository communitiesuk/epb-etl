# frozen_string_literal: true

describe UseCase::Extract do
  class ExtractRequestStub
    def body
      JSON.parse(
        {
          'job': { 'ASSESSOR': %w[TEST000000] },
          'configuration': {
            'extract': {
              'queries': {
                'ASSESSOR': {
                  'query':
                    "SELECT * FROM assessors WHERE ASSESSOR_KEY = 'TEST000000'",
                  'multiple': false,
                },
              },
            },
            'transform': {
              'queue_url':
                "https://sqs.eu-west-2.amazonaws.com/1234567890/transform",
              'rules': [
                {
                  'from': %w[data ASSESSOR FIRST_NAME], 'to': %w[data firstName]
                },
              ],
            },
            'load': {
              'endpoint': {
                'uri':
                  "http://test-endpoint/api/schemes/<%= scheme_id %>/assessors/<%= scheme_assessor_id %>",
                'method': "put",
              },
            },
          },
          'data': { 'ASSESSOR': { 'FIRST_NAME': "Joe" } },
        }.to_json,
      )
    end
  end

  context "when extracting data from trigger" do
    it "extracts the data" do
      request = ExtractRequestStub.new
      container = Container.new(false)
      message_gateway_fake = MessageGatewayFake.new
      database_gateway_fake = DatabaseGatewayFake.new
      container.set_object(:message_gateway, message_gateway_fake)
      container.set_object(:database_gateway, database_gateway_fake)
      extract = described_class.new(request, container)
      response = extract.execute

      expect(response).to eq(
        JSON.parse(
          {
            job: { ASSESSOR: %w[TEST000000] },
            configuration: {
              extract: {
                queries: {
                  ASSESSOR: {
                    multiple: false,
                    query:
                      "SELECT * FROM assessors WHERE ASSESSOR_KEY = 'TEST000000'",
                  },
                },
              },
              transform: {
                queue_url:
                  "https://sqs.eu-west-2.amazonaws.com/1234567890/transform",
                rules: [
                  { from: %w[data ASSESSOR FIRST_NAME], to: %w[data firstName] },
                ],
              },
              load: {
                endpoint: {
                  method: "put",
                  uri:
                    "http://test-endpoint/api/schemes/<%= scheme_id %>/assessors/<%= scheme_assessor_id %>",
                },
              },
            },
            data: {
              ASSESSOR: {
                DATE_OF_BIRTH: "1980-11-01 00:00:00.000000",
                FIRST_NAME: "Joe",
                SURNAME: "Testerton",
              },
            },
          }.to_json,
        ),
      )
    end
  end
end
