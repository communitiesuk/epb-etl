module Helper
  def self.bury(hash, *args)
    if args.count < 2
      raise ArgumentError, '2 or more arguments required'
    elsif args.count == 2
      hash[args[0]] = args[1]
    else
      arg = args.shift
      hash[arg] = {} unless hash[arg]
      bury(hash[arg], *args) unless args.empty?
    end

    hash
  end

  class Transform
    def self.date_format(date, format)
      Date.parse(date).strftime(format)
    end

    def self.map(key, input_map)
      JSON.parse(JSON.generate(input_map))[key.to_s]
    end

    def self.escape(value)
      CGI::escape value
    end

    def self.populate(_key, value)
      value
    end

    def self.cast(value, type)
      casting_method = "to_#{type}"
      value.send(casting_method)
    end
  end
end
