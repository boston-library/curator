# frozen_string_literal: true

module Curator
  class Filestreams::MetadataSerializer < Filestreams::FileSetSerializer
    build_schema_as_json do
      attributes :exemplary_image_of
    end
  end
end
