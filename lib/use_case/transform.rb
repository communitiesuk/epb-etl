# frozen_string_literal: true

module UseCase
  class Transform < UseCase::Base
    def initialize(request, container)
      @message_gateway = container.fetch_object :message_gateway

      super
    end

    def execute
      response =
        JSON.parse(
          {
            job: @request.body["job"],
            configuration: @request.body["configuration"],
          }.to_json,
        )

      rules = @request.body["configuration"]["transform"]["rules"]

      rules.each do |rule|
        source_data = nil

        unless rule["from"].nil?
          if rule["from"].include? "*"
            wildcard = rule["from"].index("*")
            from_before, from_after = rule["from"].each_slice(wildcard).to_a

            from_after.shift

            source_data = []

            before_source = @request.body.dig(*from_before)

            selects_multiple =
              !from_after.filter { |value| value.is_a? Array }.empty?

            before_source.each do |value|
              if selects_multiple
                object = {}
                from_after[0].each { |key| object[key] = value.dig(*key) }
                source_data << object
              else
                source_data << value.dig(*from_after)
              end
            end
          else
            source_data = @request.body.dig(*rule["from"])
          end
        end

        if rule.keys.include? "convert"
          rule["convert"].each do |conversion|
            args = conversion["args"]
            args.unshift source_data

            source_data = Helper::Transform.send conversion["type"], *args
          end
        end

        if rule["to"].include? "*"
          wildcard = rule["to"].index("*")
          to_before, to_after = rule["to"].each_slice(wildcard).to_a

          to_after.shift

          source_data =
            source_data.map do |values|
              new_values = {}

              values.each do |key, _value|
                idx = from_after[0].index(key)
                new_values[to_after[0][idx]] = values.delete key
              end

              new_values
            end

          Helper.bury(response, *to_before, source_data)
        else
          Helper.bury(response, *rule["to"], source_data)
        end
      end

      @message_gateway.write(ENV["NEXT_SQS_URL"], response)
    end
  end
end
