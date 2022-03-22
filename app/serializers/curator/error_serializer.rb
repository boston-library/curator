# frozen_string_literal: true

module Curator
  class ErrorSerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      root_key :error, :errors

      attributes :status, :title, :detail, :source
    end

    # schema_as_xml root: :error do
    #   attributes :status, :title, :detail, :source
    # end
  end
end
