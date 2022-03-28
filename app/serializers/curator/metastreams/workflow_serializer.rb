# frozen_string_literal: true

module Curator
  class Metastreams::WorkflowSerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      root_key :workflow, :workflows

      include Curator::Metastreams::JsonWorkflowable
    end
  end
end
