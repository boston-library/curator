# frozen_string_literal: true

module Curator
  class Filestreams::FileSetSerializer < CuratorSerializer
    build_schema_as_json do
      root_key :file_set, :file_sets

      attributes :file_name_base, :position

      attribute :file_set_type do |file_set|
        record.file_set_type.demodulize.downcase
      end

      one :file_set_of do
        attributes :ark_id
      end

      one :pagination, if: ->(record) { record.pagination.present? } do
        attributes :page_label, :page_type, :hand_side
      end

      one :metastreams do
        has_one :administrative do
          include Curator::Metastreams::JsonAdministratable
        end
        has_one :workflow do
          include Curator::Metastreams::JsonWorkflowable
        end
      end
    end
  end
end
