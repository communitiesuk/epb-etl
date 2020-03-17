# frozen_string_literal: true

class LogitAdapterFake
  attr_reader :data

  def initialize
    @data = []
  end

  def connected?
    true
  end

  def write(stage, event, job)
    @data << JSON.parse(
        {
            stage: stage,
            event: event,
            job: job
        }.to_json
    )
  end
end
