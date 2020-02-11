# frozen_string_literal: true

module Curator
  class Filestreams::FileSetSerializer < CuratorSerializer
    schema_as_json root: :file_set do
      attributes :file_name_base, :position
      attribute(:file_set_type) { |record| record.file_set_type.demodulize.downcase }

      node :file_set_of, target: :key do
        attributes :ark_id
      end

      node :pagination, if: ->(record, _serializer_params) { record.pagination.present? } do
        attributes :page_label, :page_type, :hand_side
      end

      node :metastreams, target: :key do
        has_one :administrative, serializer: 'Curator::Metastreams::AdministrativeSerializer'
        has_one :workflow, serializer: 'Curator::Metastreams::WorkflowSerializer'
      end
    end
  end
end
