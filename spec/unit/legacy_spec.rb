require "legacy"

describe Legacy do
  let(:db) do
    Legacy.new(ENV["ORACLE_USER"], ENV["ORACLE_PASSWORD"], ENV["ORACLE_HOST"])
  end

  it 'can connect to the Oracle DB' do
    expect(db).to be_a(Legacy)
  end

  it 'can execute a query' do
    db.query("SELECT * FROM HCR.HCR_ADDRESSES")
  end

  it 'cannot insert a new address' do
    expect {
      db.query("INSERT INTO HCR.HCR_ADDRESSES ('HCR_ADDRESS_KEY', 'UNIQUE_PROPERTY_REF_NO') VALUES(1, 2)")
    }.to raise_error(OCIError)
  end
end