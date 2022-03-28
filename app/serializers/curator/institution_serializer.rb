# frozen_string_literal: true

module Curator
  class InstitutionSerializer < CuratorSerializer
    build_schema_as_json do
      root_key :institution, :institutions

      attributes :abstract, :name, :url

      has_one :location do
        include Curator::ControlledTerms::JsonName
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
