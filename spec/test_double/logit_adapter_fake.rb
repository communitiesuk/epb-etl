# frozen_string_literal: true

class LogitAdapterFake
  attr_reader :data

  def initialize
    @data = []
  end

  def connected?
    true
  end

  def write(stage, event, data)
    @data << JSON.generate(
        {
            stage: stage,
            event: event,
            data: data
        }
    )
  end
end
