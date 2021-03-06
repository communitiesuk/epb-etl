class DatabaseGatewayFake
  def initialize(data = nil)
    @data =
      if data.nil?
        JSON.parse(
          [
            {
              DATE_OF_BIRTH: "1980-11-01 00:00:00.000000",
              FIRST_NAME: "Joe",
              SURNAME: "Testerton",
            },
          ].to_json,
        )
      else
        data
      end
  end

  def read(query)
    return @data[0] if @data && !query["multiple"]

    @data
  end
end
