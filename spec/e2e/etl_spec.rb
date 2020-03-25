# frozen_string_literal: true

require 'docker'
require 'ruby-oci8'

WebMock.allow_net_connect!

describe 'E2E::Etl', order: :defined do
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
        begin
          conn.exec 'create table ASSESSORS (ASSESSOR_KEY varchar(20), FIRST_NAME varchar(20), SURNAME varchar(20), DATE_OF_BIRTH varchar(30), ASSESSOR_ID varchar(20), ORGANISATION_KEY integer)'
          conn.exec "insert into ASSESSORS values ('12345678', 'Joe', 'Testerton', '1980-11-01 00:00:00.000000', 'TEST000001', 142)"
          conn.exec "insert into ASSESSORS values ('23456789', 'Joe', 'Testerton', '1980-11-01 00:00:00.000000', 'TEST/000000', 144)"
          conn.exec 'create table ASSESSOR_COVERAGE (ASSESSOR_KEY varchar(20), POSTCODE varchar(20))'
          conn.exec "insert into ASSESSOR_COVERAGE values ('12345678', 'SW1A 2AA')"
          conn.exec "insert into ASSESSOR_COVERAGE values ('12345678', 'SW2A 3AA')"
          conn.exec "insert into ASSESSOR_COVERAGE values ('23456789', 'SW2A 3AA')"
          conn.exec "insert into ASSESSOR_COVERAGE values ('23456789', 'SW3A 4AA')"
          conn.commit
        rescue OCIError => e
          @container.kill
          @container.stop
          @container.delete(force: true)
          Docker::Volume.prune
          sleep 1

          raise StandardError, 'Failed to run queries! ' + e.message
        end
        @oracle_has_started = true
      rescue OCIError
        @oracle_has_started = false
        sleep 10
      end
    end

    @sqs_adapter = SqsAdapterFake.new
    @logit_adapter = LogitAdapterFake.new
    oracle_adapter = Adapter::OracleAdapter.new

    message_gateway = Gateway::MessageGateway.new @sqs_adapter
    database_gateway = Gateway::DatabaseGateway.new oracle_adapter
    log_gateway = Gateway::LogGateway.new @logit_adapter

    container = Container.new false
    container.set_object :message_gateway, message_gateway
    container.set_object :database_gateway, database_gateway
    container.set_object :log_gateway, log_gateway

    @handler = Handler.new container
  end

  after :context do
    @container.kill
    @container.stop
    @container.delete(force: true)
    Docker::Volume.prune; sleep 1
  end

  context 'when data is supplied' do
    ENV['DATABASE_URL'] = 'sys/Oradoc_db1@//localhost:1521/ORCLCDB.LOCALDOMAIN as sysdba'

    it 'triggers the creation of extraction jobs' do
      ENV['ETL_STAGE'] = 'trigger'
      trigger_notification = JSON.parse File.open('spec/event/e2e-sns-trigger-input.json').read
      expected_trigger_output = JSON.parse File.open('spec/event/e2e-sqs-message-extract-input.json').read

      @handler.process event: trigger_notification

      expect(@sqs_adapter.read).to eq(expected_trigger_output)
      expect(@logit_adapter.data).to include JSON.generate({
                                                             stage: 'trigger',
                                                             event: 'start',
                                                             data: { job: nil }
                                                           })
    end

    it 'extracts the data from the database' do
      ENV['ETL_STAGE'] = 'extract'
      extract_event = JSON.parse File.open('spec/event/e2e-sqs-message-extract-input.json').read
      expected_extract_output = JSON.parse File.open('spec/event/e2e-sqs-message-transform-input.json').read

      @handler.process event: extract_event

      expect(@sqs_adapter.read).to eq(expected_extract_output)
      expect(@logit_adapter.data).to include JSON.generate({
                                                             stage: 'extract',
                                                             event: 'start',
                                                             data: {
                                                               job: {
                                                                 "ASSESSOR": ['23456789'],
                                                                 "POSTCODE_COVERAGE": ['23456789']
                                                               }
                                                             }
                                                           })
      expect(@logit_adapter.data).to include JSON.generate({
                                                             stage: 'extract',
                                                             event: 'finish',
                                                             data: {
                                                               job: {
                                                                 "ASSESSOR": ['23456789'],
                                                                 "POSTCODE_COVERAGE": ['23456789']
                                                               }
                                                             }
                                                           })
    end

    it 'transforms the data to the correct format' do
      ENV['ETL_STAGE'] = 'transform'
      expected_transform_output = JSON.parse File.open('spec/event/e2e-sqs-message-load-input.json').read

      @handler.process event: @sqs_adapter.read

      expect(@sqs_adapter.read).to eq(expected_transform_output)
      expect(@logit_adapter.data).to include JSON.generate({
                                                             stage: 'transform',
                                                             event: 'start',
                                                             data: {
                                                               job: {
                                                                 "ASSESSOR": ['23456789'],
                                                                 "POSTCODE_COVERAGE": ['23456789']
                                                               }
                                                             }
                                                           })
      expect(@logit_adapter.data).to include JSON.generate({
                                                             stage: 'transform',
                                                             event: 'finish',
                                                             data: {
                                                               job: {
                                                                 "ASSESSOR": ['23456789'],
                                                                 "POSTCODE_COVERAGE": ['23456789']
                                                               }
                                                             }
                                                           })
    end

    it 'sends the data to the endpoint in the correct format' do
      ENV['ETL_STAGE'] = 'load'
      http_stub = stub_request(:put, 'http://test-endpoint/api/schemes/1/assessors/TEST%2F000000')
                  .to_return(body: JSON.generate(message: 'ok'), status: 200)

      @handler.process event: @sqs_adapter.read

      expect(WebMock).to have_requested(:put, 'http://test-endpoint/api/schemes/1/assessors/TEST%2F000000')
        .with(body: JSON.generate(
          firstName: 'Joe',
          lastName: 'Testerton',
          dateOfBirth: '1980-11-01',
          postcodeCoverage: ['SW2A 3AA', 'SW3A 4AA']
        ))

      expect(@logit_adapter.data).to include JSON.generate({
                                                             stage: 'load',
                                                             event: 'start',
                                                             data: {
                                                               job: {
                                                                 "ASSESSOR": ['23456789'],
                                                                 "POSTCODE_COVERAGE": ['23456789']
                                                               }
                                                             }
                                                           })
      expect(@logit_adapter.data).to include JSON.generate({
                                                             stage: 'load',
                                                             event: 'finish',
                                                             data: {
                                                               job: {
                                                                 "ASSESSOR": ['23456789'],
                                                                 "POSTCODE_COVERAGE": ['23456789']
                                                               }
                                                             }
                                                           })

      remove_request_stub(http_stub)
    end
  end
end
