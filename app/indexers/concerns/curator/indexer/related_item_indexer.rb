# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module RelatedItemIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          to_field %w(related_item_host_tim related_item_host_ssim) do |record, accumulator|
            record.descriptive.host_collections.each { |hcol| accumulator << hcol.name }
          end
          to_field %w(related_item_series_tim related_item_series_ssim), obj_extract('descriptive', 'series')
          to_field %w(related_item_subseries_tim related_item_subseries_ssim), obj_extract('descriptive', 'subseries')
          to_field %w(related_item_subsubseries_tim related_item_subsubseries_ssim), obj_extract('descriptive', 'subsubseries')
          to_field 'related_item_constituent_tsim', obj_extract('descriptive', 'related', 'constituent')
          to_field 'related_item_isreferencedby_ssm', obj_extract('descriptive', 'related', 'referenced_by_url')
        end
      end
    end
  end
end
