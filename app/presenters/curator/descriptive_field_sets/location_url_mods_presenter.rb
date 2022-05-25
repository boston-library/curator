# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::LocationUrlModsPresenter
    # This class is for serializing <mods:location><mods:url> elements/attributes
    attr_reader :url, :usage, :access, :note
    #
    # @param[required] url [String]
    # @param[optional] :usage [String]
    # @param[optional] :access [String]
    # @param[optional] :note [String]
    # @returns [Curator::DescriptiveFieldSets::LocationUrlModsPresenter] instance
    def initialize(url, usage: nil, access: nil, note: nil)
      @url = url
      @usage = usage
      @access = access
      @note = note
    end
  end
end
