# frozen_string_literal: true

module Gateway
  class DatabaseGateway
    def initialize(adapter)
      @adapter = adapter
    end

    def read(query)
      result = @adapter.read(query['query'])

      return result[0] if result && !query['multiple']

      result
    end
  end
end
