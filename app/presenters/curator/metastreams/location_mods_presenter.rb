# frozen_string_literal: true

module Curator
  class Metastreams::LocationModsPresenter
    attr_reader :physical_location_name, :holding_simple, :uri_list

    def initialize(physical_location_name: nil, holding_simple: nil, uri_list: [])
      @physical_location_name = physical_location_name
      @holding_simple = holding_simple
      @uri_list = uri_list
    end

    def blank?
      physical_location_name.blank? && holding_simple.blank? && uri_list.blank?
    end
  end
end
