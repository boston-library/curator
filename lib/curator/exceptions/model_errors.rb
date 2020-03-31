# frozen_string_literal: true

module Curator::Exceptions
  class InvalidRecord < ModelErrorWrapper
    def initialize(model_errors: {})
      super(model_errors: model_errors)
    end
  end
end
