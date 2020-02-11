# frozen_string_literal: true

class OracleAdapterFake
  def initialize(data)
    @data = data
  end

  def read(_query)
    @data
  end
end
