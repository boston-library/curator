# frozen_string_literal: true

module Curator::Exceptions
  class InvalidRecord < ModelError
    def initialize(model_errors: {})
      super(model_errors: model_errors)
      @status = :unprocessable_entity
      @title = 'Unprocessable Entity'
    end
  end
end
