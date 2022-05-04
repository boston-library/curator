# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::RelatedItemModsPresenter
    # This class is for serializing <mods:relatedItem> elements/attributes
    # NOTE: #title_info is for <mods:relatedItem><mods:titleInfo><mods:title> elements if a :title_label is given
    attr_reader :type, :title_info, :xlink, :display_label
    #
    # @param[required] type [String] - One of the values in Curator::DescriptiveFieldSets::RELATED_TYPES constant
    # @param[optional] :title_label [String]
    # @param[optional] :xlink [String]
    # @param[optional] :display_label [String]
    # @return [Curator::DescriptiveFieldSets::RelatedItemModsPresenter]
    def initialize(type, title_label: nil, xlink: nil, display_label: nil)
      @type = type
      @xlink = xlink
      @display_label = display_label
      @title_info = Curator::DescriptiveFieldSets::Title.new(label: title_label) if title_label
    end
  end
end
