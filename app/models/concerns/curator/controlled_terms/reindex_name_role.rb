# frozen_string_literal: true

module Curator
  module ControlledTerms
    module ReindexNameRole
      extend ActiveSupport::Concern

      included do
        after_update_commit :reindex_descriptable_objects

        private

        def reindex_descriptable_objects
          puts "HOLLA CALLBACK"
          desc_name_roles.each do |desc_name_role|
            desc_name_role.descriptive.descriptable.update_index
          end
        end
      end
    end
  end
end
