require "queue"
require "database"
require "legacy"

describe "Subscribe" do
  let(:legacy) do
    Legacy.new(ENV["ORACLE_USER"], ENV["ORACLE_PASSWORD"], ENV["ORACLE_HOST"])
  end

  let(:database) do
    Database.new(ENV["POSTGRES_USER"], ENV["POSTGRES_PASSWORD"], ENV["POSTGRES_HOST"])
  end

  let(:queue) do
    Queue.new(ENV["SQS_QUEUE"], ENV["SQS_REGION"])
    end

  let(:create_message) do
    cursor = legacy.query("SELECT * FROM HCR.HCR_ADDRESSES WHERE ROWNUM <= 1")

    row = cursor.fetch

    queue.add_message(row.to_json)
  end

  let(:get_message) do
    messages = queue.get_message(1)

    JSON.parse(messages.first.body)
  end

  context "with an item arriving from SQS" do
    it "can see the object" do
      create_message

      expect(queue.get_message(1).size).to be(1)
    end

    it "can get the body of a message" do
      create_message
      data = get_message

      expect(data).to be_a(Object)
    end

    it "can create a table storing this stuff" do
      result = database.query("CREATE TABLE address(id serial primary key, data jsonb)")

      expect(result).to be_a(PG::Result)
    end

    it "can add an item to the table" do
      create_message
      data = get_message

      expect(database.query("SELECT * FROM address").each.size).to be(0)

      database.query("INSERT INTO address VALUES(DEFAULT, '"+data.to_json+"')")

      expect(database.query("SELECT * FROM address").each.size).to be(1)
    end

    it "can manipulate the data" do
      create_message
      data = get_message

      data[0] = 1050

      database.query("INSERT INTO address VALUES(DEFAULT, '"+data.to_json+"')")

      expect(database.query("SELECT * FROM address").each.size).to be(2)
    end

    it "can clean up" do
      expect(database.query("DROP TABLE address")).to be_a(PG::Result)
    end
  end
end