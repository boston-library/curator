# frozen_string_literal: true

module Curator
  class Metastreams::LocationModsPresenter
    # This class acts as a wrapper for serializing <mods:location> sub elements/attributes
    attr_reader :physical_location_name, :holding_simple, :uri_list

    # @param[optional] :physical_location_name [String]
    # @param[optional] :holding_simple [Curator::Metastreams::HoldingSimpleModsPresenter]
    # @param[optional] :uri_list [Array Curator::DescriptiveFieldSets::LocationUrlModsPresenter]
    # @return [Curator::Metastreams::LocationModsPresenter]
    # NOTE: Due to the way <mods:location> elements display this class should be initialized with either physical_location AND holding simple OR just uri uri_list
    # See Curator::Metastreams::LocationModsDecorator#to_a for example

    def initialize(physical_location_name: nil, holding_simple: nil, uri_list: [])
      @physical_location_name = physical_location_name
      @holding_simple = holding_simple
      @uri_list = uri_list
    end

    # @return [Boolean] - Needed for serializer
    def blank?
      physical_location_name.blank? && holding_simple.blank? && uri_list.blank?
    end
  end
end
