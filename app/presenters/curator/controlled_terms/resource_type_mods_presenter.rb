# frozen_string_literal: true

module Curator
  class ControlledTerms::ResourceTypeModsPresenter
    # This class is for serializing <mods:typeOfResource> elements/attributes
    attr_reader :resource_type_manuscript, :resource_type

    delegate :label, to: :resource_type, allow_nil: true

    #
    # @param[optional] resource_types [Array[Curator::ControlledTerms::ResourceType]]
    # @param[optional] :resource_type_manuscript [Boolean[default false]]
    # @return [Array[Curator::ControlledTerms::ResourceTypeModsPresenter]]
    def self.wrap_multiple(resource_types = [], resource_type_manuscript: false)
      resource_types.map { |rt| new(rt, resource_type_manuscript: resource_type_manuscript) }
    end

    #
    # @param[required] resource_type [Curator::ControlledTerms::ResourceType]
    # @param[optional] :resource_type_manuscript Boolean[default false]
    # @return [Curator::ControlledTerms::ResourceTypeModsPresenter]
    def initialize(resource_type, resource_type_manuscript: false)
      @resource_type = resource_type
      @resource_type_manuscript = resource_type_manuscript
    end

    # @return [String | nil] used for determining displayLabel attribute value
    def manuscript_label
      resource_type_manuscript? ? 'yes' : nil
    end

    def resource_type_manuscript?
      @resource_type_manuscript
    end
  end
end
