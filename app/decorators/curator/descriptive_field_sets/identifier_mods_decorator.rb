# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::IdentifierModsDecorator < Decorators::BaseDecorator
    include Curator::DigitalObjectable
    # This class wraps and delegates a Curator::Metastreams::Descriptive to display/serialize multiple <mods:identifier> elements
    # Curator::DescriptiveFieldSets::IdentifierModsDecorator#initialize
    ## @param obj [Curator::Metastreams::Descriptive]
    ## @returns [Curator::DescriptiveFieldSets::IdentifierModsDecorator] instance
    ## USAGE:
    ### NOTE: using to_a on the decorator instance is the preferred way of usage in mods serializer
    ### desc = Curator.metastreams.descriptive_class.for_serialization.find_by(..)
    ### identifier_list = Curator::DescriptiveFieldSets:IdentifierModsDecorator.new(desc).to_a
    def identifiers
      return [] if __getobj__.blank?

      __getobj__.identifier if __getobj__.respond_to?(:identifier)
    end

    def ark_identifier
      return if digital_object.blank?

      digital_object.ark_identifier
    end

    def has_uri_identifier?
      return false if filtered_identifiers.blank?

      filtered_identifiers.any? { |ident| ident.type == 'uri' }
    end

    # @returns [Array[Curator::DescriptiveFieldSets::Identifier]] - Exclude uri-preview and iiif-manifest from the identifier list
    def filtered_identifiers
      return @filtered_identifiers if defined?(@filtered_identifiers)

      return @filtered_identifiers = [] if identifiers.blank?

      @filtered_identifiers = identifiers.select { |ident| DescriptiveFieldSets::EXCLUDED_MODS_IDENTIFIER_TYPES.exclude?(ident.type) }
    end

    # @returns [Array[Curator::DescriptiveFieldSets::Identifier]] - Only return the ark identifer if there is NO uri identifer present in the filtered list
    # NOTE: this is needed based on how <mods:identifier> elements are displayed mods
    def to_a
      return Array.wrap(filtered_identifiers) if has_uri_identifier?

      Array.wrap(ark_identifier) + Array.wrap(filtered_identifiers)
    end

    # @return [Boolean] - Needed for mods serializer
    def blank?
      return true if __getobj__.blank?

      digital_object.blank? && identifiers.blank?
    end
  end
end
