# frozen_string_literal: true

describe 'Acceptance::LogitAdapter' do
  context 'when logging an event' do
    before do
      stub_request(:post, 'https://api.logit.io/v2')
          .to_return(body: JSON.generate(message: 'Thanks'), status: 202)
    end

    after do
      WebMock.reset!
    end

    let(:logit_adapter) { Adapter::LogitAdapter.new }

    it 'does not raise an error' do
      expect do
        logit_adapter.write 'stage', 'event', { test: true }
      end.to_not raise_error
    end

    it 'sends the log event to the logit api' do
      ENV['LOGIT_API_KEY'] = 'testtesttest'

      logit_adapter.write 'stage', 'event', { test: true }

      expect(WebMock).to have_requested(:post, 'https://api.logit.io/v2')
                             .with(body: JSON.generate(
                                 stage: 'stage',
                                 event: 'event',
                                 data: {
                                     test: true
                                 }
                             ))
    end
  end
end
