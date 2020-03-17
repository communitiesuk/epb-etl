# frozen_string_literal: true

require 'ruby-oci8'

module Adapter
  class OracleAdapter < Adapter::BaseAdapter
    def initialize
      @oracle = nil
    end

    def read(query)
      records = []
      cursor = @oracle.parse(query)

      cursor.exec
      cursor.fetch_hash { |r| records << r }
      cursor.close

      records
    end

    def connect
      @oracle = OCI8.new ENV['DATABASE_URL']
    end

    def connected?
      !@oracle.nil?
    end
  end
end
