# frozen_string_literal: true

module Curator
  class Metastreams::SubjectNameModsPresenter
    # This class acts as a wrapper for serializing <mods:subject><mods:name><mods:name_part> elements/attributes
    attr_reader :name, :name_parts

    delegate :authority_code, :authority_base_url, :value_uri, :name_type, to: :name, allow_nil: true

    # @param[required] [Curator::ControlledTerms::Name]
    # @param[optional] name_parts [Array[Curator::Mappings::NamePartModsPresenter]]
    # @return [Curator::Metastreams::SubjectNameModsPresenter] instance
    def initialize(name, name_parts = [])
      @name = name
      @name_parts = name_parts
    end

    # @return [Boolean] - Needed for serializer
    def blank?
      name.blank? && name_parts.blank?
    end
  end
end
