# frozen_string_literal: true

module Curator
  class DigitalObjectSerializer < CuratorSerializer
    schema_as_json root: :digital_object do
      node :admin_set, target: :key do
        attribute :ark_id
      end

      node :contained_by, target: :key do
        attribute :ark_id
      end

      node :is_member_of_collection, target: :key do
        attribute :ark_id
      end

      node :metastreams, target: :key do
        has_one :administrative, serializer: Curator::Metastreams::AdministrativeSerializer
        has_one :descriptive, serializer: Curator::Metastreams::DescriptiveSerializer
        has_one :workflow, serializer: Curator::Metastreams::WorkflowSerializer
      end
    end
  end
end
