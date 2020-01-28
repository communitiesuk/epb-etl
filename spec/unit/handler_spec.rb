require 'rspec'

describe Handler do
  context 'when invoking processor with event and context' do
    it 'does not raise an error' do
      expect do
        described_class.process(event: {}, context: {})
      end.not_to raise_error
    end
  end
end
