# frozen_string_literal: true

module Curator
  class DigitalObjectSerializer < CuratorSerializer
    schema_as_json root: :digital_object do
      attributes :ark_id
    end
    # def metastreams
    #   {}.merge(
    #     ActiveModelSerializers::SerializableResource.new(object.administrative, serializer: Metastreams::AdministrativeSerializer, root: 'administrative').as_json
    #   ).merge(
    #     ActiveModelSerializers::SerializableResource.new(object.descriptive, serializer: Metastreams::DescriptiveSerializer, root: 'descriptive').as_json
    #   ).merge(
    #     ActiveModelSerializers::SerializableResource.new(object.workflow, serializer: Metastreams::WorkflowSerializer, root: 'workflow').as_json
    #   )
    # end
  end
end
