# frozen_string_literal: true

module Curator
  class CuratorSerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      attributes :ark_id, :created_at, :updated_at
    end
  end
end
