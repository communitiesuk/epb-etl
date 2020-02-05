module Gateway
  class MessageGateway
    def initialize(adapter)
      @adapter = adapter
    end

    def read
      @adapter.read
    end

    def write(data)
      @adapter.write(data)
    end
  end
end
