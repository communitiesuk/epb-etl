module Helpers
  class Transform
    def self.date_format(date, format)
      Date.parse(date).strftime(format)
    end
  end
end
