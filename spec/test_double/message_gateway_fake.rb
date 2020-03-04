# frozen_string_literal: true

class MessageGatewayFake
  attr_reader :data

  def initialize(data = nil)
    @data = data
  end

  def write(_queue_url, data)
    @data = data
  end
end
