# frozen_string_literal: true

describe Gateway::DatabaseGateway do
  context 'when reading from the adapter' do
    it 'returns the result of the query' do
      oracle_adapter = OracleAdapterFake.new(
        [
          {
            "ASSESSOR_KEY": 'TEST000000',
            "DATE_OF_BIRTH": '1980-11-01 00:00:00.000000',
            "FIRST_NAME": 'Joe',
            "SURNAME": 'Testerton',
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
            ]
          }
        ]
      )

      database_gateway = Gateway::DatabaseGateway.new(oracle_adapter)
      response = database_gateway.read(
        'query' => "SELECT * FROM assessors WHERE ASSESSOR_KEY = 'TEST000000'",
        'multiple' => false
      )

      expect(response).to eq(
        ASSESSOR_LOCATION: [1234, 1234, [746_745, 523_646, nil], nil, nil],
        DATE_OF_BIRTH: '1980-11-01 00:00:00.000000',
        FIRST_NAME: 'Joe',
        SURNAME: 'Testerton',
        ASSESSOR_KEY: 'TEST000000'
      )
    end

    it 'returns multiple results of a query' do
      oracle_adapter = OracleAdapterFake.new(
        [
          {
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
            ]
          }
        ]
      )

      database_gateway = Gateway::DatabaseGateway.new(oracle_adapter)
      response = database_gateway.read(
        'query' => "SELECT * FROM postcodes WHERE ASSESSOR_KEY = 'TEST000000'",
        'multiple' => true
      )

      expect(response).to eq([{ ASSESSOR_LOCATION: [1234, 1234, [746_745, 523_646, nil], nil, nil] }])
    end

    it 'raises an error if there is no result' do
      oracle_adapter = OracleAdapterFake.new(nil)

      database_gateway = Gateway::DatabaseGateway.new(oracle_adapter)

      expect do
        database_gateway.read(
          'query' => "SELECT * FROM postcodes WHERE ASSESSOR_KEY = 'TEST000000'",
          'multiple' => true
        )
      end.to raise_error an_instance_of Errors::ResultEmpty
    end
  end
end
