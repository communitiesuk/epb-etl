# frozen_string_literal: true

module Gateway
  class LogGateway < BaseGateway
    def initialize(adapter)
      @adapter = adapter
    end

    def write(stage, event, job)
      @adapter.connect unless @adapter.connected?

      @adapter.write(stage, event, job)
    end
  end
end
