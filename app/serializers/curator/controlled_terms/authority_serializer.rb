# frozen_string_literal: true

module Curator
  class ControlledTerms::AuthoritySerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      root_key :authority, :authorities

      attributes :name, :code, :base_url
    end
  end
end
