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
          case term_type
          when 'License'
            licensees.find_each do |descriptive|
              descriptive.descriptable.update_index
            end
          when 'RightsStatement'
            rights_statement_of.find_each do |descriptive|
              descriptive.descriptable.update_index
            end
          when 'Name', 'Role'
            desc_name_roles.find_each do |desc_name_role|
              desc_name_role.descriptive.descriptable.update_index
            end
            if term_type == 'Name'
              physical_locations_of.find_each do |descriptive|
                descriptive.descriptable.update_index
              end
            end
          else
            desc_terms.find_each do |desc_term|
              desc_term.descriptive.descriptable.update_index
            end
          end
        end
      end
    end
  end
end
