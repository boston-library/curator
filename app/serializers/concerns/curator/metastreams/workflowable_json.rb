# frozen_string_literal: true

module Curator
  module Metastreams
    module WorkflowableJson
      extend ActiveSupport::Concern
      # NOTE: these need to be included WITHIN a build_schema_as_json block
      # ex. build_schema_as_json do
      #       include Curator::Metastreams::JsonWorkflowable
      #     end
      # OR (in cases of defining associations)
      # build_schema_as_json do
      #   one :workflow do
      #      include Curator::Metastreams::JsonWorkflowable
      #   end
      # end
      included do
        attributes :publishing_state, :processing_state, :ingest_origin
      end
    end
  end
end
