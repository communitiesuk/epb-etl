require 'rspec'

describe Helper::Transform do
  context 'when transforming a nil value' do
    it 'outputs nil for a nil date' do
      output_date = described_class.date_format(nil, '%Y-%m-%d')

      expect(output_date).to eq nil
    end

    it 'outputs nil when type casting it' do
      output_date = described_class.cast(nil, 'i')

      expect(output_date).to eq nil
    end
  end

  context 'when transforming a date to another format' do
    it 'outputs in the expected format' do
      input_date = '1985-10-15 03:00:00.0000'
      output_date = described_class.date_format(input_date, '%Y-%m-%d')

      expect(output_date).to eq '1985-10-15'
    end
  end

  context 'when transforming by populating with hard-coded data' do
    it 'outputs the hard-coded input data' do
      output = described_class.populate(nil, [])

      expect(output).to eq []
    end
  end

  context 'when transforming a value to another in a map' do
    it 'outputs the expected value from the map' do
      output = described_class.map('100', { 100 => '101' })

      expect(output).to eq '101'
    end

    it 'outputs the expected value from the map when the map has a symbol' do
      output = described_class.map('test_sym', { test_sym: '5000' })

      expect(output).to eq '5000'
    end

    it 'outputs the expected value when the key is an integer but the input is keyed on strings' do
      output = described_class.map('100', { '100' => 800 })

      expect(output).to eq 800
    end
  end

  context 'when transforming a value by escaping it' do
    it 'outputs an escaped version of the input value' do
      output = described_class.escape('TEST/0000')

      expect(output).to eq 'TEST%2F0000'
    end
  end

  context 'when transforming a value by type casting it' do
    it 'outputs an integer when given a string' do
      output = described_class.cast('1', 'i')

      expect(output).to be 1
    end

    it 'outputs a string when given an integer' do
      output = described_class.cast(1, 's')

      expect(output).to eq '1'
    end

    it 'outputs a float when given a string' do
      output = described_class.cast('1.45', 'f')

      expect(output).to eq 1.45
    end

    it 'outputs a boolean false when given an empty string' do
      output = described_class.cast('', 'b')

      expect(output).to eq false
    end

    it 'outputs a boolean false when given truthy string' do
      output = described_class.cast('Y', 'b')

      expect(output).to eq true
    end
  end

  context 'when transforming a wildcard value' do
    it 'applies the given conversions to each key of the wildcard values' do
      input_value = JSON.parse(JSON.generate([{
          "castToInt": "76",
      },{
          "castToInt": "392",
      }]))

      output = described_class.wildcard(input_value,
                                        JSON.parse(JSON.generate({
                                           "castToInt": [{
                                                             "type": "cast",
                                                             "args": ["i"]
                                                         }]
                                       })))

      expect(output).to eq JSON.parse(JSON.generate([{
                                "castToInt": 76,
                            },{
                                "castToInt": 392,
                            }]))
    end
  end
end
