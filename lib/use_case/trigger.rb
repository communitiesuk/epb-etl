# frozen_string_literal: true

module UseCase
  class Trigger < UseCase::Base
    def initialize(request, container)
      @message_gateway = container.fetch_object :message_gateway
      @database_gateway = container.fetch_object :database_gateway

      super
    end

    def execute
      scanners = @request.body['configuration']['trigger']['scanners']

      scanners.each_pair do |name, config|
        records = @database_gateway.read({'query' => config['scan'], 'multiple' => true})

        records.each do |record|
          extract = config['extract'].dup
          params = {primary_key: record.values.first}

          begin
            extract['query'] = params.nil? ?
                      extract['query'] :
                      ERB.new(extract['query']).result_with_hash(params)
          rescue NameError => e
            raise Errors::RequestWithInvalidParams, e.message, e.backtrace
          end

          job = @request.body.dup

          job['configuration']['extract']['queries'][name] = extract

          @message_gateway.write("sns-queue-url", job)
        end
      end
    end
  end
end
