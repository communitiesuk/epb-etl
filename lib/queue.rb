require 'aws-sdk-sqs'

class Queue
  def initialize(queue_name, region)
    @queue = Aws::SQS::Client.new(region: region)

    @queue_url = @queue.get_queue_url(queue_name: queue_name).queue_url
  end

  def add_message(data)
    result = @queue.send_message({
        queue_url: @queue_url,
        message_body: data
    })

    result.message_id
  end

  def get_message(quantity = 1)
    result = @queue.receive_message({
                            queue_url: @queue_url,
                            message_attribute_names: ["All"],
                            max_number_of_messages: quantity,
                            wait_time_seconds: 0
                        })

    result.messages
  end

  def delete_message(id)
    @queue.delete_message({
        queue_url: @queue_url,
        receipt_handle: id
                          })
  end
end