# frozen_string_literal: true

module Curator
  class ControlledTerms::AuthoritySerializer < Curator::Serializers::AbstractSerializer
    schema_as_json root: :authority do
      attributes :name, :code, :base_url
    end
  end
end
