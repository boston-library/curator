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
          if term_type == 'License'
            licensees.each do |descriptive|
              descriptive.descriptable.update_index
            end
          else
            iterator = case term_type
                       when 'Name', 'Role'
                         :desc_name_roles
                       else
                         :desc_terms
                       end
            public_send(iterator).each do |desc_mapping|
              desc_mapping.descriptive.descriptable.update_index
            end
          end
        end
      end
    end
  end
end
