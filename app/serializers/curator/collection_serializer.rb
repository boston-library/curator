# frozen_string_literal: true

module Curator
  class CollectionSerializer < CuratorSerializer
    build_schema_as_json do
      root_key :collection, :collections

      attributes :abstract, :name

      has_one :institution do
        attributes :ark_id
      end

      nested :metastreams do
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
