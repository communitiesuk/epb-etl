# frozen_string_literal: true

require 'erb'

module UseCase
  class Trigger < UseCase::Base
    def initialize(request, container)
      @message_gateway = container.fetch_object :message_gateway
      @database_gateway = container.fetch_object :database_gateway

      super
    end

    def execute
      config = @request.body['configuration']['trigger']

      records = @database_gateway.read({ 'query' => config['scan'], 'multiple' => true })

      records.each do |record|
        job = @request.body.dup
        config['extract'].each_pair do |extract_name, extract_query|
          params = { primary_key: record.values.first }
          query = extract_query.dup

          begin
            query['query'] = if params.nil?
                               query['query']
                             else
                               ERB.new(query['query']).result_with_hash(params)
                             end
          rescue NameError => e
            raise Errors::RequestWithInvalidParams, e.message, e.backtrace
          end

          Helper.bury(job, 'job', extract_name, [params[:primary_key]])

          job['configuration']['extract']['queries'][extract_name] = query
        end

        @message_gateway.write(ENV['NEXT_SQS_URL'], job)
      end
    end
  end
end
