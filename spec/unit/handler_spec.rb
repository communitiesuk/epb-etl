require 'rspec'

describe Handler do
  context 'when invoking processor with event' do
    it 'does not raise an error' do
      ENV['ETL_STAGE'] = 'extract'

      expect do
        handler = described_class.new
        handler.process(message: {
            Records: []
        })
      end.not_to raise_error
    end
  end
end
