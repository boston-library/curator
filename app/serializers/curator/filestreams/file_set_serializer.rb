# frozen_string_literal: true

module Curator
  class Filestreams::FileSetSerializer < CuratorSerializer
    schema_as_json do
      attributes :file_name_base, :position

      node :file_set_of, target: :key do
        attributes :ark_id
      end

      node :pagination do
        attributes :page_label, :page_type, :hand_side
      end

      node :metastreams, target: :key do
        has_one :administrative, serializer: 'Curator::Metastreams::AdministrativeSerializer'
        has_one :workflow, serializer: 'Curator::Metastreams::WorkflowSerializer'
      end
    end
  end
end
