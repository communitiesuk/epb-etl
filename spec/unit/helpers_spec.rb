require 'rspec'

describe Helpers::Transform do
  context 'when transforming a date to another format' do
    it 'outputs in the expected format' do
      input_date = '1985-10-15 03:00:00.0000'
      output_date = described_class.date_format(input_date, '%Y-%m-%d')

      expect(output_date).to eq '1985-10-15'
    end
  end
end
