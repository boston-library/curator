# frozen_string_literal: true

module Curator
  class Metastreams::TocModsPresenter
    attr_reader :label, :xlink

    def initialize(label: nil, xlink: nil)
      @label = label
      @xlink = xlink
    end

    def blank?
      label.blank? && xlink.blank?
    end
  end
end
