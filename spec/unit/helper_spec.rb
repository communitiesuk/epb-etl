require 'rspec'

describe Helper::Transform do
  context 'when transforming a date to another format' do
    it 'outputs in the expected format' do
      input_date = '1985-10-15 03:00:00.0000'
      output_date = described_class.date_format(input_date, '%Y-%m-%d')

      expect(output_date).to eq '1985-10-15'
    end
  end

  context 'when transforming a value to another in a map' do
    it 'outputs the expected value from the map' do
      output = described_class.map('100', {
          100 => '101'
      })

      expect(output).to eq '101'
    end

    it 'outputs the expected value from the map when the map has a symbol' do
      output = described_class.map('test_sym', {
          test_sym: '5000'
      })

      expect(output).to eq '5000'
    end

    it 'outputs the expected value when the key is an integer but the input is keyed on strings' do
      output = described_class.map('100', {
          '100' => 800
      })

      expect(output).to eq 800
    end
  end
end
