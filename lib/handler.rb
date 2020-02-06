# frozen_string_literal: true

class Handler
  def initialize(container)
    @container = container
  end

  def process(message:)
    normalised_message = JSON.parse(JSON.generate(message))

    etl_stage = ENV['ETL_STAGE'].capitalize

    use_case_constant = UseCase.const_get(etl_stage)

    normalised_message['Records'].each do |event|
      request = Boundary.const_get(etl_stage + 'Request').new event['body']
      use_case = use_case_constant.new(request, @container)

      use_case.execute
    end
  rescue NameError
    raise Errors::EtlStageInvalid
  end
end
