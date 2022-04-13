# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::RelatedModsDecorator < Decorators::Base
    def related
      super if __getobj__.respond_to?(:related)
    end

    def related_series
      return @related_series if defined?(@related_series)

      return @related_series = [] if !__getobj__.respond_to?(:series) || __getobj__.series.blank?

      series_item = build_related_series(fetch_related_type(:series), title_label: __getobj__.series)
      sub_series_item = build_related_series(fetch_related_type(:series), title_info: __getobj__.subseries) if __getobj__.subseries.present?
      sub_sub_series_item =  build_related_series(fetch_related_type(:series), title_info: __getobj__.subsubseries) if __getobj__.subsubseries.present?

      sub_series_item << sub_sub_series_item if sub_series_item.present? && sub_sub_series_item.present?

      series_item << sub_series_item if sub_series_item.present?

      @related_series = [series_item]
    end

    def related_hosts
      return @related_hosts if defined?(@related_hosts)

      return @related_hosts = [] if host_collection_names.blank?

      @related_hosts = host_collection_names.map { |hcn| DescriptiveFieldSets::RelatedItemModsPresenter.new(fetch_related_type(:host), title_label: hcn) }
    end

    def related_constituent
      return @related_constituent if defined?(@related_constituent)

      return @related_constituent = [] if !related.respond_to?(:constituent) || related.constituent.blank?

      @related_constituent = 'TODO'
    end

    def host_collection_names
      return @host_collection_names if defined?(@host_collection_names)

      return @host_collection_names = [] if !__getobj__.respond_to?(:host_collections)

      @host_collection_names = __getobj__.host_collections.names
    end

    def to_a
      Array.wrap(related_hosts) + Array.wrap(related_series)
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
      DescriptiveFieldSets::RelatedSeriesModsPresenter.new(DescriptiveFieldSets::RelatedItemModsPresenter.new(type, title_label: title_label)
    end
  end
end
