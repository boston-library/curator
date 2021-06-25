# frozen_string_literal: true

module Curator
  class Filestreams::DocumentSerializer < Filestreams::FileSetSerializer
    schema_as_json do
      attributes :exemplary_image_of

      attribute(:document_primary_url) { |record, serializer_params| serializer_params[:show_primary_url].presence ? record.document_primary&.url : nil }
    end
  end
end
