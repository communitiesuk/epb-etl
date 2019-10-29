require "queue"
require "legacy"

require "pry"

describe "Publish" do
  let(:legacy) do
    Legacy.new(ENV["ORACLE_USER"], ENV["ORACLE_PASSWORD"], ENV["ORACLE_HOST"])
  end

  let(:queue) do
    Queue.new(ENV["SQS_QUEUE"], ENV["SQS_REGION"])
  end

  context "with first row of addresses" do
    it 'can get the address' do
      cursor = legacy.query("SELECT * FROM HCR.HCR_ADDRESSES WHERE ROWNUM <= 1")

      json_string = cursor.fetch.to_json

      expect(json_string).to be_a(String)
    end

    it 'can get the address, and add it to SQS' do
      cursor = legacy.query("SELECT * FROM HCR.HCR_ADDRESSES WHERE ROWNUM <= 1")

      row = cursor.fetch

      queue.add_message(row.to_json)

      expect(queue.get_message(10).size).to be(1)
    end
  end
end