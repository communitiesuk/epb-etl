# frozen_string_literal: true

module Gateway
  class DatabaseGateway
    def initialize(oracle_adapter)
      @oracle_adapter = oracle_adapter
    end

    def read(query)
      result = @oracle_adapter.read(query['query'])

      raise Errors::ResultEmpty.new, 'There are no results for this query' if result == nil

      return result[0] if result && !query['multiple']

      result
    end
  end
end
