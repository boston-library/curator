# frozen_string_literal: true

module Curator
  class Metastreams::WorkflowSerializer < CuratorSerializer
    schema_as_json root: :workflow do
      attributes :publishing_state, :processing_state, :ingest_origin
    end
  end
end
