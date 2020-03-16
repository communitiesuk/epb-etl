# frozen_string_literal: true

module Gateway
  class BaseGateway
    def read
      raise StandardError.new, 'Gateway does not implement read()'
    end

    def write
      raise StandardError.new, 'Gateway does not implement write()'
    end
  end
end
