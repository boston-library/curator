# frozen_string_literal: true

module Curator
  class Metastreams::DescriptiveSerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      root_key :descriptive, :descriptives

      include Curator::Metastreams::DescriptableJson
    end

    build_schema_as_mods do
      include Curator::Metastreams::DescriptableMods
    end
  end
end
