# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::RelatedItemModsPresenter
    RELATED_TYPES={
      host: 'host',
      constituent: 'constituent',
      series: 'series',
      review: 'reviewOf',
      referenced_by: 'isReferencedBy',
      references: 'references',
      other_format: 'otherFormat'
    }.freeze

    attr_reader :type, :title_info, :xlink, :display_label

    def initialize(type, title_label: nil, xlink: nil, display_label: nil)
      @type = type
      @xlink = xlink
      @display_label = display_label
      @title_info = Curator::DescriptiveFieldSets::Title.new(label: title_label) if title_label
    end
  end
end
