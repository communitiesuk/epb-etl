module Helpers
  class Transform
    def self.date_format(date, format)
      Date.parse(date).strftime(format)
    end

    def self.map(key, input_map)
      input_map[key].nil? ? input_map[key.to_sym] : input_map[key]
    end
  end
end
