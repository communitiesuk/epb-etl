require "pg"

class Database
  def initialize(user, password, host)
    @connection = PG.connect(:host => host, :user => user, :password => password)
  end

  def query(sql)
    @result = @connection.exec sql
  end
end