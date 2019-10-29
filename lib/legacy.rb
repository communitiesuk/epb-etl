require "oci8"

class Legacy
  def initialize(user, password, host)
    string = user+"/"+password+"@"+host

    @connection = OCI8.new(string)
  end

  def query(sql)
    @result = @connection.exec sql
  end
end