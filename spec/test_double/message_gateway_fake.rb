# frozen_string_literal: true

class MessageGatewayFake
  def initialize(data = nil)
    @data = data
  end

  def write(_queue_url, data)
    @data = data
  end
end
