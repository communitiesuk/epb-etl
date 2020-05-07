# frozen_string_literal: true

require "aws-sdk-sqs"

module Adapter
  class SqsAdapter < Adapter::BaseAdapter
    def initialize(sqs = nil)
      @sqs = sqs
    end

    def write(queue_url, message_body)
      if message_body.nil? || message_body.empty?
        raise Errors::SqsClientWithoutMessageBody
      end

      @sqs.send_message(
        queue_url: queue_url, message_body: JSON.generate(message_body),
      )
    rescue ArgumentError => e
      if e.message.include?("invalid endpoint")
        raise Errors::SqsClientHasInvalidQueueUrl
      end

      raise
    end
  end
end
