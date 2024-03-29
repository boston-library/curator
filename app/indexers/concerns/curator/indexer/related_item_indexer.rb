# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module RelatedItemIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          to_field %w(related_item_host_tim related_item_host_ssim) do |rec, acc|
            acc.concat rec.descriptive.host_collections.map(&:name) if rec.descriptive&.host_collections
          end
          to_field %w(related_item_series_ti related_item_series_ssi), obj_extract('descriptive', 'series')
          to_field %w(related_item_subseries_ti related_item_subseries_ssi), obj_extract('descriptive', 'subseries')
          to_field %w(related_item_subsubseries_ti related_item_subsubseries_ssi), obj_extract('descriptive', 'subsubseries')
          to_field 'related_item_constituent_tsim', obj_extract('descriptive', 'related', 'constituent')
          to_field 'related_item_isreferencedby_ssm', obj_extract('descriptive', 'related', 'referenced_by', 'to_json')
          to_field 'related_item_preceding_ssm', obj_extract('descriptive', 'related', 'preceding', 'to_json')
          to_field 'related_item_succeeding_ssm', obj_extract('descriptive', 'related', 'succeeding', 'to_json')
          to_field 'related_item_other_format_tsim', obj_extract('descriptive', 'related', 'other_format')
          to_field 'related_item_references_ssm', obj_extract('descriptive', 'related', 'references_url')
          to_field 'related_item_review_ssm', obj_extract('descriptive', 'related', 'review_url')
        end
      end
    end
  end
end
