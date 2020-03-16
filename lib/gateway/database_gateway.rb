# frozen_string_literal: true

module Gateway
  class DatabaseGateway < BaseGateway
    def initialize(adapter)
      @adapter = adapter
    end

    def read(query)
      @adapter.connect unless @adapter.connected?

      result = @adapter.read(query['query'])

      raise Errors::ResultEmpty if result.nil?

      result && !query['multiple'] ? result[0] : result
    end
  end
end
