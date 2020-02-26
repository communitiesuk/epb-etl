module Helpers
  class Transform
    def self.date_format(date, format)
      Date.parse(date).strftime(format)
    end

    def self.map(key, input_map)
      JSON.parse(JSON.generate(input_map))[key.to_s]
    end
  end
end
