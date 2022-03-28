# frozen_string_literal: true

module Curator
  class DigitalObjectSerializer < CuratorSerializer
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
          include Curator::Metastreams::JsonAdministratable
        end

        has_one :descriptive do
          include Curator::Metastreams::JsonDescriptable
        end

        has_one :workflow do
          include Curator::Metastreams::JsonWorkflowable
        end
      end
    end
  end
end
