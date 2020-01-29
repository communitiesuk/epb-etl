# frozen_string_literal: true

module UseCase
  class Load < UseCase::Base
    def execute
      validate
    end
  end
end
