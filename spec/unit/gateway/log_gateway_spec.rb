# frozen_string_literal: true

describe Gateway::LogGateway do
  context 'when trying to read from the adapter' do
    it 'raises a standard error' do
      log_gateway = described_class.new(nil)
      expect { log_gateway.read }.to raise_error instance_of StandardError
    end
  end

  context 'when writing to the logstash adapter' do
    it 'emits a log event' do
      logstash_adapter = LogstashAdapterFake.new
      log_gateway = described_class.new logstash_adapter

      log_gateway.write('test', 'event', {})

      expect(logstash_adapter.data).to eq(JSON.parse([{
        stage: 'test',
        event: 'event',
        job: {}
      }].to_json))
    end
  end
end
