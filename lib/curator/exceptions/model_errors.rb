# frozen_string_literal: true

module Curator::Exceptions
  class InvalidRecord < ModelError
    def initalize(model_errors: {})
      super(model_errors: errors)
      @status = :unprocessable_entity
      @title = "Unprocessable Entity"
    end
  end
end
