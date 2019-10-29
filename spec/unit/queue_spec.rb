require "queue"

describe Queue do
  let!(:queue) do
    Queue.new(ENV["SQS_QUEUE"], ENV["SQS_REGION"])
  end

  it 'can clean up' do
    queue.get_message(10).each do |message|
      queue.delete_message(message.receipt_handle)
    end
  end

  context "creating messages" do
    it 'can grab a SQS queue' do
      expect(queue).to be_a(Queue)
    end

    it 'can create a queue item' do
      expect(queue.add_message('{"id": "'+rand(100).to_s+'"}').size).to be(36)
    end
  end

  context "reading messages" do
    it 'can read a message' do
      result = queue.get_message(1)

      run = false

      result.each do |message|
        result = JSON.parse(message.body)
        expect(result["id"]).to be_a(String)

        run = true
      end

      expect(run).to be(true)
    end

    it 'can delete all messages' do
      queue.add_message('{"id": "'+rand(100).to_s+'"}')

      result = queue.get_message(10)

      run = false

      result.each do |message|
        result = JSON.parse(message.body)
        expect(result["id"]).to be_a(String)

        run = true

        queue.delete_message(message.receipt_handle)
      end

      expect(run).to be(true)

      expect(queue.get_message(10).size).to be(0)
    end
  end
end