# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::RelatedSeriesModsPresenter
    attr_reader :related_item, :sub_series

    delegate :type, :xlink, :display_label, :title_info, to: :related_item, allow_nil: true

    def initialize(related_item)
      @related_item = related_item
      @sub_series = nil
    end

    def sub_series=(sub_series_item)
      @sub_series = sub_series_item
    end
  end
end
