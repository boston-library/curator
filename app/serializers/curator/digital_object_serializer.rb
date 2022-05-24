# frozen_string_literal: true

module Curator
  class DigitalObjectSerializer < CuratorSerializer
    # Overloaded initializer so the record is always set as DigitalObject#descriptive if the adapter_key is :mods
    def initialize(record, params = {}, adapter_key: :json)
      super
      @record = @record.descriptive if adapter_key == :mods
    end

    build_schema_as_json do
      root_key :digital_object, :digital_objects

      has_one :admin_set do
        attributes :ark_id
      end

      has_one :contained_by do
        attributes :ark_id
      end

      has_many :is_member_of_collection do
        attributes :ark_id
      end

      one :metastreams do
        has_one :administrative do
          include Curator::Metastreams::AdministratableJson
        end

        has_one :descriptive do
          include Curator::Metastreams::DescriptableJson
        end

        has_one :workflow do
          include Curator::Metastreams::WorkflowableJson
        end
      end
    end

    build_schema_as_mods do
      include Curator::Metastreams::DescriptableMods
    end
  end
end
