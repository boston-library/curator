# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::RelatedModsDecorator < Decorators::BaseDecorator
    def related
      super if __getobj__.respond_to?(:related)
    end

    def related_series
      return @related_series if defined?(@related_series)

      return @related_series = [] if !__getobj__.respond_to?(:series) || __getobj__.series.blank?

      series_item = build_related_series(fetch_related_type(:series), __getobj__.series)
      sub_series_item = build_related_series(fetch_related_type(:series), __getobj__.subseries) if __getobj__.subseries.present?
      sub_sub_series_item = build_related_series(fetch_related_type(:series), __getobj__.subsubseries) if __getobj__.subsubseries.present?

      sub_series_item.sub_series = sub_sub_series_item if sub_series_item.present? && sub_sub_series_item.present?

      series_item.sub_series = sub_series_item if sub_series_item.present?

      @related_series = series_item
    end

    def related_hosts
      return @related_hosts if defined?(@related_hosts)

      return @related_hosts = [] if host_collection_names.blank?

      @related_hosts = host_collection_names.map { |hcn| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:host), title_label: hcn) }
    end

    def related_constituent
      return @related_constituent if defined?(@related_constituent)

      return @related_constituent = [] if related.constituent.blank? || !related.respond_to?(:constituent)

      @related_constituent = DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:constituent), title_label: related.constituent)
    end

    def related_referenced_by
      return @related_referenced_by if defined?(@related_referenced_by)

      return @related_referenced_by = [] if related.blank?

      @related_referenced_by = related.referenced_by.map { |ref_by| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:referenced_by), xlink: ref_by.url, display_label: ref_by.label) }
    end

    def related_references
      return @related_references if defined?(@related_references)

      return @related_references = [] if related.blank?

      @related_references = related.references_url.map { |reference_url| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:references), xlink: reference_url) }
    end

    def related_review_of
      return @related_review_of if defined?(@related_review_of)

      return @related_review_of = [] if related.blank?

      @related_review_of = related.review_url.map { |review_of_url| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:review), xlink: review_of_url) }
    end

    def related_other_format
      return @related_other_format if defined?(@related_other_format)

      return @related_other_format = [] if related.blank?

      @related_other_format = related.other_format.map { |other_format| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:other_format), title_label: review_of_url) }
    end

    def host_collection_names
      return @host_collection_names if defined?(@host_collection_names)

      return @host_collection_names = [] if !__getobj__.respond_to?(:host_collections)

      @host_collection_names = __getobj__.host_collections.names
    end

    def to_a
      Array.wrap(related_hosts) + Array.wrap(related_series) + Array.wrap(related_constituent) + Array.wrap(related_references) + Array.wrap(related_review_of) + Array.wrap(related_referenced_by)
    end

    def blank?
      return false if __getobj__.blank?

      related.blank? && related_hosts.blank? && related_series.blank?
    end

    protected

    def fetch_related_type(type_key)
      DescriptiveFieldSets::RelatedItemModsPresenter::RELATED_TYPES.fetch(type_key)
    end

    private

    def build_related_series(type, title_label)
      Rails.logger.info type.awesome_inspect
      Rails.logger.info title_label.awesome_inspect
      DescriptiveFieldSets::RelatedSeriesModsPresenter.new(DescriptiveFieldSets::RelatedItemModsPresenter.new(type, title_label: title_label))
    end
  end
end
