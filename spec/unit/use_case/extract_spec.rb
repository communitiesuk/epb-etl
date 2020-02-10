# frozen_string_literal: true

describe UseCase::Extract do
  class DatabaseGatewayFake
    def read(query)
      result = JSON.parse(
        [
          {
            DATE_OF_BIRTH: '1980-11-01 00:00:00.000000',
            FIRST_NAME: 'Joe',
            SURNAME: 'Testerton'
          }
        ].to_json
      )

      return result[0] if result && !query['multiple']

      result
    end
  end

  class MessageGatewayFake
    def read
      @data
    end

    def write(data)
      @data = data
    end
  end

  class ExtractRequestStub
    def body
      JSON.parse(
        {
          "configuration": {
            "endpoint": {
              "uri": 'http://test-endpoint/api/schemes/1/assessors/TEST000000',
              "method": 'put'
            },
            "rules": [
              {
                "from": %w[data ASSESSOR FIRST_NAME],
                "to": %w[data firstName]
              }
            ],
            "extract": {
              "queries": {
                "ASSESSOR": {
                  "query": "SELECT * FROM assessors WHERE ASSESSOR_KEY = 'TEST000000'",
                  "multiple": false
                }
              }
            }
          },
          "data": {
            "ASSESSOR": {
              "FIRST_NAME": 'Joe'
            }
          }
        }.to_json
      )
    end
  end

  context 'when extracting data from trigger' do
    it 'extracts the data' do
      request = ExtractRequestStub.new
      container = Container.new(false)
      message_gateway_fake = MessageGatewayFake.new
      database_gateway_fake = DatabaseGatewayFake.new
      container.set_object(:message_gateway, message_gateway_fake)
      container.set_object(:database_gateway, database_gateway_fake)
      extract = described_class.new(request, container)
      response = extract.execute

      expect(response).to eq(JSON.parse({
        'configuration' => {
          'endpoint' => {
            'method' => 'put',
            'uri' => 'http://test-endpoint/api/schemes/1/assessors/TEST000000'
          },
          'extract' => {
            'queries' => {
              'ASSESSOR' => {
                'multiple' => false,
                'query' => "SELECT * FROM assessors WHERE ASSESSOR_KEY = 'TEST000000'"
              }
            }
          },
          'rules' => [{
            'from' => %w[data ASSESSOR FIRST_NAME],
            'to' => %w[data firstName]
          }]
        },
        'data' => {
          'ASSESSOR' => {
            DATE_OF_BIRTH: '1980-11-01 00:00:00.000000',
            FIRST_NAME: 'Joe',
            SURNAME: 'Testerton'
          }
        }
      }.to_json))
    end
  end
end
