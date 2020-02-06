module Gateway
  class DatabaseGateway
    def initialize(adapter)
      @adapter = adapter
    end

    def read(query)
      result = @adapter.read(query['query'])

      if result && !query['multiple']
        return result[0]
      end

      result
    end
  end
end
