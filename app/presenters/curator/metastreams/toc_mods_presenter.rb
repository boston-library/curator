# frozen_string_literal: true

module Curator
  class Metastreams::TocModsPresenter
    # This class is for serializing  <mods:tableOfContents> elements/attributes
    attr_reader :label, :xlink

    # Creates 2 instances of this class to serialize based on if the keyword arguments are present or not
    # One will serialize/display as <mods:tableOfContents>:label</mod:tableOfContents>
    # The other will serialize/display as <mods:tableOfContents xlink:href=':xlink'/>
    # @param[optional] :label [String]
    # @param[optional] :xlink [String]
    # @return [Array[Curator::Metastreams::TocModsPresenter instance]] Or [Array[Empty]]
    def self.wrap_multiple(label: nil, xlink: nil)
      return [] if label.blank? && xlink.blank?

      toc_attrs = {}
      toc_attrs[:label] = label if label.present?
      toc_attrs[:xlink] = xlink if xlink.present?

      toc_attrs.keys.map { |k| new(k => toc_attrs[k]) }
    end

    # @param[optional] :label
    # @param[optional] :xlink
    # @return [Curator::Metastreams::TocModsPresenter] instance
    def initialize(label: nil, xlink: nil)
      @label = label
      @xlink = xlink
    end

    # @return [Boolean] - Needed for serializer
    def blank?
      label.blank? && xlink.blank?
    end
  end
end
