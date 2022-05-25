# frozen_string_literal: true

module Curator
  class ControlledTerms::GenreModsDecorator < Decorators::BaseDecorator
    # DESCRIPTION: This class wraps and delegates Curator::ControlledTerms::Genre objects to serialize/display <mods:genre> elements
    # Curator::ControlledTerms::GenreModsDecorator#initialize
    ## @param obj [Curator::ControlledTerms::Genre]
    ## @return [Curator::ControlledTerms::GenreModsDecorator] instance
    ## USAGE:
    ### NOTE: preferred usage in serializer is to use wrap_multiple method
    ### desc = Curator.metastreams.descriptive_class.for_serialization.find_by(..)
    ### genres = Curator::ControlledTerms:GenreModsDecorator.wrap_multiple(desc.genres)
    # @param genres [Array[Curator::ControlledTerms::Genre]]
    # @return [Array[Curator::ControlledTerms::GenreModsDecorator]]
    def self.wrap_multiple(genres = [])
      genres.map(&method(:new))
    end

    # @return [String] - Used for getting the value for <mods:genre>
    def label
      super if __getobj__.respond_to?(:label)
    end

    # @return [String | nil] - Used for getting the value for the <mods:genre authority=''> attribute
    def authority
      __getobj__.authority_code if __getobj__.respond_to?(:authority_code)
    end

    # @return [String | nil] - Used for getting the value for the <mods:genre authorityURI=''> attribute
    def authority_uri
      __getobj__.authority_base_url if __getobj__.respond_to?(:authority_base_url)
    end

    # @return [String | nil] - Used for getting the value for the <mods:genre valueURI=''> attribute
    def value_uri
      super if __getobj__.respond_to?(:value_uri)
    end

    # @return [String] - Used for getting the value for the <mods:genre displayLabel=''> attribute
    def display_label
      return if __getobj__.blank? || !__getobj__.respond_to?(:basic?)

      __getobj__.basic? ? 'general' : 'specific'
    end

    # @return [Boolean] - Needed for mods serializer
    def blank?
      return true if __getobj__.blank?

      label.blank? && authority.blank? && authority_uri.blank? && value_uri.blank? && display_label.blank?
    end
  end
end
