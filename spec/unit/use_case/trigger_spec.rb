# frozen_string_literal: true

describe UseCase::Trigger do
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


  class TriggerRequestStub
    def body
      JSON.parse(
        {
          'configuration': {
              trigger: {
                  scanners: {
                      ASSESSOR: {
                          scan: "SELECT ASSESSOR_KEY FROM assessors",
                          extract: {
                              query: "SELECT * FROM assessors WHERE ASSESSOR_KEY = '<%= primary_key %>'",
                              multiple: false
                          }
                      }
                  }
              },
            'extract': {
              'queries': {
                'ASSESSOR': {
                  'query': 'SELECT * FROM assessors WHERE ASSESSOR_KEY = \'TEST000000\'',
                  'multiple': false
                }
              }
            },
            'transform': {
              'queue_url': 'https://sqs.eu-west-2.amazonaws.com/1234567890/transform',
              'rules': [
                {
                  'from': %w[data ASSESSOR FIRST_NAME],
                  'to': %w[data firstName]
                }
              ]
            },
            'load': {
              'endpoint': {
                'uri': 'http://test-endpoint/api/schemes/<%= scheme_id %>/assessors/<%= scheme_assessor_id %>',
                'method': 'put'
              }
            }
          }
        }.to_json
      )
    end
  end

  context 'when receiving an SNS notification' do
    let(:database_gateway_fake) { spy(DatabaseGatewayFake.new) }
    let(:trigger) do
      request = TriggerRequestStub.new
      container = Container.new(false)
      message_gateway_fake = MessageGatewayFake.new

      container.set_object(:message_gateway, message_gateway_fake)
      container.set_object(:database_gateway, database_gateway_fake)
      trigger = described_class.new(request, container)
    end

    it 'scans the database' do
      trigger.execute

      expect(database_gateway_fake).to have_received(:read)
                                           .with("SELECT ASSESSOR_KEY FROM assessors")
    end

  end
end
