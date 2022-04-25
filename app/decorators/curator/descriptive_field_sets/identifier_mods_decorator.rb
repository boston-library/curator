# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::IdentifierModsDecorator < Decorators::BaseDecorator
    def digital_object
      super if __getobj__.respond_to?(:digital_object)
    end

    def identifiers
      return [] if __getobj__.blank?

      __getobj__.identifier if __getobj__.respond_to?(:identifier)
    end

    def ark_identifier
      return if digital_object.blank?

      digital_object.ark_identifier
    end

    def to_a
      Array.wrap(ark_identifier) + Array.wrap(identifiers)
    end

    def blank?
      return true if __getobj__.blank?

      ark_identifier.blank? && identifiers.blank?
    end
  end
end
