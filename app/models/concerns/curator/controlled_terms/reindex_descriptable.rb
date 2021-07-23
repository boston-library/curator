# frozen_string_literal: true

module Curator
  module ControlledTerms
    module ReindexDescriptable
      extend ActiveSupport::Concern

      included do
        after_update_commit :reindex_descriptable_objects

        private

        def reindex_descriptable_objects
          term_type = self.class.name.demodulize
          object_ids = []
          case term_type
          when 'License'
            object_ids = licensees.pluck(:digital_object_id)
          when 'RightsStatement'
            object_ids = rights_statement_of.pluck(:digital_object_id)
          when 'Name', 'Role'
            object_ids = desc_name_roles.joins(:descriptive).pluck(:'metastreams_descriptives.digital_object_id')
            object_ids += physical_locations_of.pluck(:digital_object_id) if term_type == 'Name'
            object_ids.uniq!
          else
            object_ids = desc_terms.joins(:descriptive).pluck(:'metastreams_descriptives.digital_object_id')
            object_ids.uniq!
          end

          return if object_ids.blank?

          # NOTE: per this comment https://github.com/sciencehistory/kithe/blob/56a65a97292c3d0e273a822080df6d1db8616cfa/app/indexing/kithe/indexable.rb#L57
          # If we are updating a batch of record in a call back without a background job we should wrap in the index_with batching: true
          Curator::Indexable.index_with(batching: true) do
            Curator.digital_object_class.for_reindex_all.where(id: object_ids).find_each(&:update_index)
          end
        end
      end
    end
  end
end
