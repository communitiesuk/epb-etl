require "database"

describe Database do
  let!(:db) do
    Database.new(ENV["POSTGRES_USER"], ENV["POSTGRES_PASSWORD"], ENV["POSTGRES_HOST"])
  end

  it 'can connect to a database' do
    expect(db).to be_a(Database)
  end

  it 'can create a table' do
    db.query("DROP TABLE IF EXISTS cars")
    db.query("CREATE TABLE cars(id INTEGER PRIMARY KEY, name VARCHAR(20), price INT)")

    expect(db.query("SELECT * FROM cars").each.size).to be(0)
  end

  it 'can insert a line' do
    db.query("INSERT INTO cars VALUES(1, 'Audi', 52642)")

    expect(db.query("SELECT * FROM cars").each.size).to be(1)
  end

  it 'can delete a line' do
    db.query("DELETE FROM cars WHERE id = 1")

    expect(db.query("SELECT * FROM cars").each.size).to be(0)
  end
end