# frozen_string_literal: true

module Curator
  class CollectionSerializer < CuratorSerializer
    schema_as_json root: :collection do
      attributes :abstract, :name

      #TODO: Add ability to configure fields for relationships whne defining schema rathe than passing them in as #serializer_params
      node :institution, target: :key do
        attribute :ark_id
      end

      node :metastreams do
        has_one :administrative, serializer: 'Curator::Metastreams::AdministrativeSerializer'
        has_one :workflow, serializer: 'Curator::Metastreams::WorkflowSerializer'
      end
    end
  end
end
