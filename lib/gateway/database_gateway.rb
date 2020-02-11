# frozen_string_literal: true

module Gateway
  class DatabaseGateway
    def initialize(oracle_adapter)
      @oracle_adapter = oracle_adapter
    end

    def read(query)
      result = @oracle_adapter.read(query['query'])

      raise Errors::ResultEmpty if result.nil?

      result && !query['multiple'] ? result[0] : result
    end
  end
end
