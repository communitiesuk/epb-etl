# frozen_string_literal: true

require 'docker'
require 'ruby-oci8'

WebMock.allow_net_connect!

describe 'Integration::OracleAdapter' do
   before :context do
    @container = nil

    @config = {
      Image: 'store/oracle/database-enterprise:12.2.0.1',
      ExposedPorts: { '1521/tcp' => {} },
      HostConfig: {
        PortBindings: {
          '1521/tcp' => [{ 'HostPort': '1521', 'HostIp': 'localhost' }]
        }
      }
    }

    @container = Docker::Container.create @config
    @container.start
    @oracle_has_started = false

    until @oracle_has_started
      begin
        conn = OCI8.new 'sys', 'Oradoc_db1', '//localhost:1521/ORCLCDB.LOCALDOMAIN', :SYSDBA

        conn.exec 'create table rates (actual varchar(10), word varchar(8), score integer)'
        conn.exec "insert into rates values ('1', 'one', 25)"
        conn.exec "insert into rates values ('2', 'two', 50)"
        conn.exec "insert into rates values ('3', 'three', 75)"
        conn.commit

        @oracle_has_started = true
      rescue OCIError
        @oracle_has_started = false
      end
    end
   end

   after :context do
    @container.kill
    @container.stop
   end

  context 'when connecting to the Oracle database' do
    it 'does not raise an error' do
      expect do
        Adapter::OracleAdapter.new OCI8.new 'sys/Oradoc_db1@//localhost:1521/ORCLCDB.LOCALDOMAIN as sysdba'
      end.not_to raise_error
    end

    it 'can select from a table' do
      oracle = OCI8.new 'sys/Oradoc_db1@//localhost:1521/ORCLCDB.LOCALDOMAIN as sysdba'
      oracle_adapter = Adapter::OracleAdapter.new oracle
      response = oracle_adapter.read('SELECT * FROM rates').first

      expect(response['SCORE']).to eq 25
    end
  end
end
