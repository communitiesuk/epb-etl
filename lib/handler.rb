# frozen_string_literal: true

class Handler
  def initialize(container)
    @container = container
  end

  def process(event:)
    normalised_event = JSON.parse(JSON.generate(event))

    etl_stage = ENV['ETL_STAGE'].capitalize

    begin
      use_case_constant = UseCase.const_get(etl_stage)
    rescue NameError
      raise Errors::EtlStageInvalid
    end

    normalised_event['Records'].each do |message|
      event_source = message["EventSource"].nil? ? message['eventSource'] : message["EventSource"]
      event_body = event_source == 'aws:sqs' ? message['body'] : message["Sns"]['Message']

      event_body = event_body.is_a?(String) ? JSON.parse(event_body) : event_body

      request = Boundary.const_get(etl_stage + 'Request').new event_body
      use_case = use_case_constant.new(request, @container)

      @container.fetch_object(:log_gateway).write ENV['ETL_STAGE'],
                                                  'start',
                                                  {job: event_body['job']}

      use_case.execute
    end
  end
end
