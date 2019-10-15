# frozen_string_literal: true
module Curator
  class DigitalObjectSerializer < CuratorSerializer
    attributes :id, :ark_id, :created_at, :updated_at, :metastreams

    def metastreams
      {}.merge(
        ActiveModelSerializers::SerializableResource.new(object.administrative, serializer: Metastreams::AdministrativeSerializer, root: 'administrative').as_json
      ).merge(
        ActiveModelSerializers::SerializableResource.new(object.descriptive, serializer: Metastreams::DescriptiveSerializer, root: 'descriptive').as_json
      ).merge(
        ActiveModelSerializers::SerializableResource.new(object.workflow, serializer: Metastreams::WorkflowSerializer, root: 'workflow').as_json
      )
    end
  end
end
