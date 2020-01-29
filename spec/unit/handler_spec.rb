require 'rspec'

describe Handler do
  context 'when invoking processor with event' do
    it 'does not raise an error' do
      expect do
        handler = described_class.new
        handler.process(event: {})
      end.not_to raise_error
    end
  end
end
