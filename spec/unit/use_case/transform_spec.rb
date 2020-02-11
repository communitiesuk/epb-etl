# frozen_string_literal: true

describe UseCase::Transform do
  class TransformRequestStub
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
            ]
          },
          "data": {
            "ASSESSOR": {
              "FIRST_NAME": 'Joe'
            }
          }
        }
          .to_json
      )
    end
  end

  context 'when transforming data from extraction' do
    it 'converts the first name to the body' do
      request = TransformRequestStub.new
      container = Container.new(false)
      message_gateway_fake = MessageGatewayFake.new
      container.set_object(:message_gateway, message_gateway_fake)
      transform = described_class.new(request, container)
      response = transform.execute

      expect(response).to eq(JSON.parse({
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
          ]

        },
        "data": {
          "firstName": 'Joe'
        }
      }.to_json))
    end
  end
end
