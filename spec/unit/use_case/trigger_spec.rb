# frozen_string_literal: true

describe UseCase::Trigger do
  class TriggerRequestStub
    def body
      JSON.parse(
        {
          'configuration': {
            'trigger': {
              'scan': 'SELECT ASSESSOR_KEY FROM assessors',
              'extract': {
                'ASSESSOR': {
                  'query':
                    "SELECT * FROM assessors WHERE ASSESSOR_KEY = '<%= primary_key %>'",
                  'multiple': false
                }
              }
            },
            'extract': { 'queries': {} }
          }
        }.to_json
      )
    end
  end

  context 'when receiving an SNS notification' do
    let(:database_gateway_fake) do
      DatabaseGatewayFake.new JSON.parse(
                                [
                                  { ASSESSOR_KEY: 'TEST000001' },
                                  { ASSESSOR_KEY: 'TEST000002' }
                                ].to_json
                              )
    end
    let(:message_gateway_fake) { MessageGatewayFake.new }
    let(:trigger) do
      request = TriggerRequestStub.new
      container = Container.new(false)

      container.set_object(:message_gateway, message_gateway_fake)
      container.set_object(:database_gateway, database_gateway_fake)
      described_class.new(request, container)
    end

    it 'scans the database' do
      allow(database_gateway_fake).to receive(:read).and_call_original

      trigger.execute

      expect(database_gateway_fake).to have_received(:read).with(
        { 'query' => 'SELECT ASSESSOR_KEY FROM assessors', 'multiple' => true }
      )
    end

    it 'gives the expected response' do
      allow(database_gateway_fake).to receive(:read).and_call_original
      allow(message_gateway_fake).to receive(:write).and_call_original

      trigger.execute

      expect(database_gateway_fake).to have_received(:read).exactly(1).times
      expect(message_gateway_fake).to have_received(:write).exactly(2).times

      expect(
        message_gateway_fake.data['configuration']['extract']['queries'][
          'ASSESSOR'
        ][
          'query'
        ]
      ).to eq "SELECT * FROM assessors WHERE ASSESSOR_KEY = 'TEST000002'"
    end
  end
end
