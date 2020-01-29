# frozen_string_literal: true

module UseCase
  class Transform < UseCase::Base
    def execute
      validate
    end
  end
end
