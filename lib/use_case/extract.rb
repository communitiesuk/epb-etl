# frozen_string_literal: true

module UseCase
  class Extract < UseCase::Base
    def execute
      validate
    end
  end
end
