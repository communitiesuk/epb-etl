require "legacy"

describe Legacy do
  it 'can connect to the Oracle DB' do
    Legacy.new(ENV["ORACLE_USER"], ENV["ORACLE_PASSWORD"], ENV["ORACLE_HOST"])
  end
end