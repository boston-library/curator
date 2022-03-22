# frozen_string_literal: true

module Curator
  class Metastreams::WorkflowSerializer < Curator::Serializers::AbstractSerializer
    schema_as_json do
      root_key :workflow, :workflows

      include Curator::Metastreams::JSONWorkflowable
    end
  end
end
