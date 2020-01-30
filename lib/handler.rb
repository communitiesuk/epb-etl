# frozen_string_literal: true

class Handler
  def initialize; end

  def process(message:)
    normalised_message = JSON.parse(JSON.generate(message))

    etl_stage = ENV['ETL_STAGE'].capitalize

    normalised_message['Records'].each do |event|
      request = Boundary.const_get(etl_stage + 'Request').new event['body']
      use_case = UseCase.const_get(etl_stage).new request

      use_case.execute
    end
  end
end
