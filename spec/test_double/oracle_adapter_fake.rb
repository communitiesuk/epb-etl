# frozen_string_literal: true

class OracleAdapterFake
  def initialize(data)
    @default_data = data
    @stubbed_queries = {}
  end

  def stub_query(query, data)
    @stubbed_queries[query] = data
  end

  def read(query)
    return @default_data unless @stubbed_queries.key? query

    @stubbed_queries[query]
  end

  def connected?
    true
  end
end
