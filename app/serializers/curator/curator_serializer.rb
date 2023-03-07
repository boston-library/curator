# frozen_string_literal: true

module Curator
  class CuratorSerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      attributes :ark_id
      attribute :created_at do |curator_resource|
        format_time_iso8601(curator_resource.iso8601)
      end

      attribute :updated_at do |curator_resource|
        format_time_iso8601(curator_resource.updated_at)
      end
    end
  end
end
