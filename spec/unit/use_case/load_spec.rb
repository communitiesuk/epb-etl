# frozen_string_literal: true

describe UseCase::Load do
  class LoadRequestStub
    def body
      JSON.parse(
        {
          "data": {
            "firstName": 'Joe',
            "lastName": 'Testerton',
            "dateOfBirth": '1985-11-25'
          },
          "configuration": {
            "load": {
              "endpoint": {
                "method": 'put',
                "uri": 'http://test-endpoint/api/schemes/1/assessors/TEST000000'
              }
            }
          }
        }.to_json
      )
    end
  end

  context 'when making an api request' do
    before do
      stub_request(:put, 'http://test-endpoint/api/schemes/1/assessors/TEST000000')
        .with(body: JSON.generate(
          firstName: 'Joe',
          lastName: 'Testerton',
          dateOfBirth: '1985-11-25'
        ))
        .to_return(status: 200)
    end

    it 'sends data to the API endpoint' do
      request = LoadRequestStub.new
      load = described_class.new(request, nil)
      response = load.execute

      expect(response.code).to eq '200'
    end
  end
end
