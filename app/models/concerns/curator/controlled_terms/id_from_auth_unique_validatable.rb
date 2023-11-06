# frozen_string_literal: true

module Curator
  module ControlledTerms
    module IdFromAuthUniqueValidatable
      extend ActiveSupport::Concern

      included do
        validates_with Curator::ControlledTerms::IdFromAuthUniquenessValidator, on: :create
      end
    end
  end
end
