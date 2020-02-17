# frozen_string_literal: true

module Adapter
  class OracleAdapter
    def initialize(oracle)
      @oracle = oracle
    end

    def read(query)
      records = []
      cursor = @oracle.parse(query)

      cursor.exec
      cursor.fetch_hash { |r| records << r }
      cursor.close

      records
    end
  end
end
