# frozen_string_literal: true

module Curator
  module ControlledTerms
    module ReindexDescriptable
      extend ActiveSupport::Concern

      included do
        after_update_commit :reindex_descriptable_objects

        private

        def reindex_descriptable_objects
          puts "HOLLA CALLBACK"
          desc_terms.each do |desc_term|
            desc_term.descriptive.descriptable.update_index
          end
        end
      end
    end
  end
end
