# frozen_string_literal: true

module Curator
  class InstitutionSerializer < CuratorSerializer
    build_schema_as_json do
      root_key :institution, :institutions

      attributes :abstract, :name, :url

      has_one :location do
        include Curator::ControlledTerms::GeographicJson
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
