# frozen_string_literal: true

module Curator
  class CollectionSerializer < CuratorSerializer
    schema_as_json root: :collection do
      attributes :ark_id, :abstract, :name, :metastreams
    end

    # def metastreams
    #   {}.merge(
    #     ActiveModelSerializers::SerializableResource.new(object.administrative, serializer: Metastreams::AdministrativeSerializer, root: 'administrative').as_json
    #   ).merge(
    #     ActiveModelSerializers::SerializableResource.new(object.workflow, serializer: Metastreams::WorkflowSerializer, root: 'workflow').as_json
    #   )
    # end
  end
end
