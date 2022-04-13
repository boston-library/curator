# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::RelatedSeriesModsPresenter
    attr_reader :series, :sub_series

    delgate :type, :title_info, to: :series, allow_nil: true

    def initalize(related_item_series)
      @series = top_series
      @sub_series = []
    end

    def <<(series_item)
      @sub_series << series_item
    end
  end
end
