# frozen_string_literal: true

module Curator
  class InstitutionSerializer < CuratorSerializer
    schema_as_json do
      attributes :abstract, :name, :url

      belongs_to :location, serializer: Curator::ControlledTerms::GeographicSerializer

      node :metastreams do
        has_one :administrative, serializer: Curator::Metastreams::AdministrativeSerializer
        has_one :workflow, serializer: Curator::Metastreams::WorkflowSerializer
      end
    end
  end
end
