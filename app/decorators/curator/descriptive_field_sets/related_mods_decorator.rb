# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::RelatedModsDecorator < Decorators::BaseDecorator
    # DESCRIPTION: This class wraps and delegates Curator::Metastreams::Descriptive objects to serialize/display <mods:relatedItem> elemenst and sub elements
    # Curator::DescriptiveFieldSets::RelatedModsDecorator#initialize
    ## @param obj [Curator::Metastreams::Descriptive]
    ## @return [Curator::DescriptiveFieldSets::RelatedModsDecorator]
    ## USAGE:
    ### NOTE: using to_a on the decorator instance is the preferred way of usage in mods serializer
    ### desc = Curator.metastreams.descriptive_class.for_serialization.find_by(..)
    ### related_mods = Curator::DescriptiveFieldSets::RelatedModsDecorator.new(desc).to_a
    def related
      super if __getobj__.respond_to?(:related)
    end

    # @return [Curator::DescriptiveFieldSets::RelatedSeriesModsPresenter] instance - This is needed for serializing/displaying nested <mods:relatedItem type='series'> elements
    def related_series
      # TODO: When adding subsubsubseries from issue https://github.com/boston-library/curator/issues/206 don't forget to modify this method to handle new field
      return @related_series if defined?(@related_series)

      return @related_series = [] if !__getobj__.respond_to?(:series) || __getobj__.series.blank?

      series_item = build_related_series(fetch_related_type(:series), __getobj__.series)
      sub_series_item = build_related_series(fetch_related_type(:series), __getobj__.subseries) if __getobj__.subseries.present?
      sub_sub_series_item = build_related_series(fetch_related_type(:series), __getobj__.subsubseries) if __getobj__.subsubseries.present?

      sub_series_item.sub_series = sub_sub_series_item if sub_series_item.present? && sub_sub_series_item.present?

      series_item.sub_series = sub_series_item if sub_series_item.present?

      @related_series = series_item
    end

    # @return [Array[Curator::DescriptiveFieldSets::RelatedItemModsPresenter]] instance - This is needed for serializing/displaying <mods:relatedItem type='host'> elements
    def related_hosts
      return @related_hosts if defined?(@related_hosts)

      return @related_hosts = [] if host_collection_names.blank?

      @related_hosts = host_collection_names.map { |hcn| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:host), title_label: hcn) }
    end

    # @return [Curator::DescriptiveFieldSets::RelatedItemModsPresenter] instance - This is needed for serializing/displaying <mods:relatedItem type='constituent'> elements
    def related_constituent
      return @related_constituent if defined?(@related_constituent)

      return @related_constituent = [] if related.constituent.blank? || !related.respond_to?(:constituent)

      @related_constituent = DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:constituent), title_label: related.constituent)
    end

    # @return [Array[Curator::DescriptiveFieldSets::RelatedItemModsPresenter]] - This is needed for serializing/displaying <mods:relatedItem type='isReferencedBy'> elements
    def related_referenced_by
      return @related_referenced_by if defined?(@related_referenced_by)

      return @related_referenced_by = [] if related.blank?

      @related_referenced_by = related.referenced_by.map { |ref_by| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:referenced_by), xlink: ref_by.url, display_label: ref_by.label) }
    end

    # @return [Array[Curator::DescriptiveFieldSets::RelatedItemModsPresenter]] - This is needed for serializing/displaying <mods:relatedItem type='isReferencedBy'> elements
    def related_references
      return @related_references if defined?(@related_references)

      return @related_references = [] if related.blank?

      @related_references = related.references_url.map { |reference_url| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:references), xlink: reference_url) }
    end

    # @return [Array[Curator::DescriptiveFieldSets::RelatedItemModsPresenter]] - This is needed for serializing/displaying <mods:relatedItem type='reviewOf'> elements
    def related_review_of
      return @related_review_of if defined?(@related_review_of)

      return @related_review_of = [] if related.blank?

      @related_review_of = related.review_url.map { |review_of_url| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:review), xlink: review_of_url) }
    end

    # @return [Array[Curator::DescriptiveFieldSets::RelatedItemModsPresenter]] - This is needed for serializing/displaying <mods:relatedItem type='otherFormat'> elements
    def related_other_format
      return @related_other_format if defined?(@related_other_format)

      return @related_other_format = [] if related.blank?

      @related_other_format = related.other_format.map { |other_format| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:other_format), title_label: other_format) }
    end

    # @return [Array[String | nil]]
    def host_collection_names
      return @host_collection_names if defined?(@host_collection_names)

      return @host_collection_names = [] if !__getobj__.respond_to?(:host_collections)

      @host_collection_names = __getobj__.host_collections.names
    end

    # @return [Array[Curator::DescriptiveFieldSets::RelatedItemModsPresenter | Curator::DescriptiveFieldSets::RelatedSeriesModsPresenter]] - this method is needed due to how <mods:relatedItem> elements are displayed/serialized in mods
    def to_a
      Array.wrap(related_hosts) + Array.wrap(related_series) + Array.wrap(related_constituent) + Array.wrap(related_references) + Array.wrap(related_review_of) + Array.wrap(related_referenced_by) + Array.wrap(related_other_format)
    end

    # @return [Boolean] - Needed for mods serializer
    def blank?
      return false if __getobj__.blank?

      related.blank? && related_hosts.blank? && related_series.blank?
    end

    protected

    def fetch_related_type(type_key)
      DescriptiveFieldSets::RELATED_TYPES.fetch(type_key)
    end

    private

    def build_related_series(type, title_label)
      DescriptiveFieldSets::RelatedSeriesModsPresenter.new(DescriptiveFieldSets::RelatedItemModsPresenter.new(type, title_label: title_label))
    end
  end
end
