require "oci8"

class Legacy
  def initialize(host, user, password)
    @connection = OCI8.new(user, password, host)
  end
end