# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module WorkflowIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          to_field 'publishing_state_ssi', obj_extract('workflow', 'publishing_state')
          to_field 'processing_state_ssi', obj_extract('workflow', 'processing_state')
        end
      end
    end
  end
end
