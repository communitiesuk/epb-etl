require "pg"

class Database
  def initialize(host, user, password)
    @connection = PG.connect(:host => host, :user => user, :password => password)
  end

  def query(sql)
    @result = @connection.exec sql
  end
end