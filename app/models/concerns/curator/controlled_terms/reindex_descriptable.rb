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
            object_ids += licensees.pluck(:digital_object_id)
          when 'RightsStatement'
            object_ids += rights_statement_of.pluck(:digital_object_id)
          when 'Name', 'Role'
            object_ids = desc_name_roles.joins(:descriptive).pluck(:'metastreams_descriptives.digital_object_id')
            if term_type == 'Name'
              object_ids += physical_locations_of.pluck(:digital_object_id)
              object_ids += desc_terms.joins(:descriptive).pluck(:'metastreams_descriptives.digital_object_id')
            end
            object_ids.uniq!
          else
            object_ids = desc_terms.joins(:descriptive).pluck(:'metastreams_descriptives.digital_object_id')
            object_ids.uniq!
          end

          return if object_ids.blank?

          Curator.digital_object_class.where(id: object_ids).find_each(&:queue_indexing_job)
        end
      end
    end
  end
end
