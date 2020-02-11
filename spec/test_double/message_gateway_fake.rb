class MessageGatewayFake
  def initialize(data = nil)
    @data = data
  end

  def write(data)
    @data = data
  end
end
