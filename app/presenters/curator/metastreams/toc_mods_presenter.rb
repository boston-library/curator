# frozen_string_literal: true

module Curator
  class Metastreams::TocModsPresenter
    attr_reader :label, :xlink

    def self.wrap_multiple(label: nil, xlink: nil)
      return [] if label.blank? && xlink.blank?

      toc_attrs = {}
      toc_attrs[:label] = label if label.present?
      toc_attrs[:xlink] = xlink if xlink.present?

      toc_attrs.keys.map { |k| new(k => toc_attrs[k]) }
    end

    def initialize(label: nil, xlink: nil)
      @label = label
      @xlink = xlink
    end

    def blank?
      label.blank? && xlink.blank?
    end
  end
end
