# frozen_string_literal: true
require 'docker'
require 'ruby-oci8'
WebMock.allow_net_connect!
describe 'E2E::Etl' do
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
        conn.exec 'create table ASSESSORS (FIRST_NAME varchar(20), SURNAME varchar(20), DATE_OF_BIRTH varchar(30), ASSESSOR_ID varchar(20))'
        conn.exec "insert into ASSESSORS values ('Joe', 'Testerton', '1980-11-01 00:00:00.000000', 'TEST000000')"
        conn.commit
        @oracle_has_started = true
      rescue OCIError
        @oracle_has_started = false
      end
    end

    @sqs_adapter = SqsAdapterFake.new
    oracle = OCI8.new 'sys/Oradoc_db1@//localhost:1521/ORCLCDB.LOCALDOMAIN as sysdba'
    oracle_adapter = Adapter::OracleAdapter.new oracle

    message_gateway = Gateway::MessageGateway.new(@sqs_adapter)
    database_gateway = Gateway::DatabaseGateway.new(oracle_adapter)

    container = Container.new false
    container.set_object(:message_gateway, message_gateway)
    container.set_object(:database_gateway, database_gateway)
    @handler = Handler.new(container)
  end

  after :context do
    @container.kill
    @container.stop
    @container.delete(force: true)
    Docker::Volume.prune
  end

  context 'when data is supplied' do
    it 'passes through the extract stage'do
      ENV['ETL_STAGE'] = 'extract'

      extract_event = JSON.parse File.open('spec/event/e2e-sqs-message-extract-input.json').read
      expected_extract_output = JSON.parse File.open('spec/event/e2e-sqs-message-transform-input.json').read

      @handler.process event: extract_event

      expect(@sqs_adapter.read).to eq(expected_extract_output)
    end

    it 'passes through the transform stage'do
      ENV['ETL_STAGE'] = 'transform'

      transform_event = JSON.parse File.open('spec/event/e2e-sqs-message-transform-input.json').read
      expected_transform_output = JSON.parse File.open('spec/event/e2e-sqs-message-load-input.json').read

      @handler.process event: transform_event

      expect(@sqs_adapter.read).to eq(expected_transform_output)
    end

    it 'send data to the endpoint'do
      ENV['ETL_STAGE'] = 'load'

      http_stub = stub_request(:put, 'http://test-endpoint/api/schemes/1/assessors/TEST000000')
                      .to_return(body: JSON.generate(message: 'ok'), status: 200)
      load_event = JSON.parse File.open('spec/event/e2e-sqs-message-load-input.json').read

      @handler.process event: load_event

      expect(WebMock).to have_requested(:put, 'http://test-endpoint/api/schemes/1/assessors/TEST000000')
                             .with(body: JSON.generate(
                                 firstName: 'Joe',
                                 lastName: 'Testerton',
                                 dateOfBirth: '1980-11-01'
                             ))

      remove_request_stub(http_stub)
    end
  end
end
