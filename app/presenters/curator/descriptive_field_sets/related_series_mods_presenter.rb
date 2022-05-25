# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::RelatedSeriesModsPresenter
    # This class is for serializing nested(ie series/subseriers/subsubseries) <mods:relatedItem='series'><mods:relatedItem='series'> elements/attributes
    attr_reader :related_item, :sub_series

    delegate :type, :xlink, :display_label, :title_info, to: :related_item, allow_nil: true
    #
    # @param[required] related_item [Curator::DescriptiveFieldSets::RelatedItemModsPresenter]
    # @return Curator::DescriptiveFieldSets::RelatedSeriesModsPresenter
    def initialize(related_item)
      @related_item = related_item
      @sub_series = nil
    end

    # @param[required] sub_series_item [Curator::DescriptiveFieldSets::RelatedSeriesModsPresenter]
    # Setter for sub_series which takes another instance of this class
    def sub_series=(sub_series_item)
      @sub_series = sub_series_item
    end
  end
end
