# frozen_string_literal: true
module CommonwealthCurator
  class Metastreams::WorkflowSerializer < CuratorSerializer
    attributes :publishing_state, :processing_state, :ingest_origin, :ingest_filename, :ingest_filepath, :ingest_datastream
  end
end
