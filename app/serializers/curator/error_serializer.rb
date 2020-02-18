# frozen_string_literal: true

module Curator
  class ErrorSerializer < Curator::Serializers::AbstractSerializer
    schema_as_json :error do
      attributes :status, :title, :detail, :source
    end

    schema_as_xml :error do
      attributes :status, :title, :detail, :source
    end
  end
end
