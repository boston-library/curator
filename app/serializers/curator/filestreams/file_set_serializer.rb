# frozen_string_literal: true

module Curator
  class Filestreams::FileSetSerializer < CuratorSerializer
    build_schema_as_json do
      root_key :file_set, :file_sets

      attributes :file_name_base, :position

      attribute :file_set_type do |resource|
        resource.file_set_type.demodulize.downcase
      end

      one :pagination do
        attributes :page_label, :page_type, :hand_side
      end

      has_one :file_set_of do
        attributes :ark_id
      end

      has_many :file_set_members_of do
        attributes :ark_id
      end

      nested :metastreams do
        include Curator::Serializers::SchemaBuilders::JSON::AlbaHelpers

        has_one :administrative do
          include Curator::Metastreams::AdministratableJson
        end

        has_one :workflow do
          include Curator::Metastreams::WorkflowableJson
        end
      end
    end
  end
end
