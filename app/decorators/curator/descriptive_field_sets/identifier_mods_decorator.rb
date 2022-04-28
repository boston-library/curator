# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::IdentifierModsDecorator < Decorators::BaseDecorator
    EXCLUDED_IDENTIFIER_TYPES = %w(iiif-manifest uri-preview).freeze

    # NOTE: The base object for this decorator class is Curator::Metastreams::Descriptive

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

    def has_uri_identifier?
      return false if filtered_identifiers.blank?

      filtered_identifiers.any? { |ident| ident.type == 'uri' }
    end

    # Exlude uri-preview and iiif-manifest from the identifier list
    def filtered_identifiers
      return @filtered_identifiers if defined?(@filtered_identifiers)

      return @filtered_identifiers = [] if identifiers.blank?

      @filtered_identifiers = identifiers.select { |ident| EXCLUDED_IDENTIFIER_TYPES.exclude?(ident.type) }
    end

    # Only return the ark identifer if there is NO uri identifer present in the filtered list
    def to_a
      return Array.wrap(filtered_identifiers) if has_uri_identifier?

      Array.wrap(ark_identifier) + Array.wrap(filtered_identifiers)
    end

    def blank?
      return true if __getobj__.blank?

      digital_object.blank? && identifiers.blank?
    end
  end
end
