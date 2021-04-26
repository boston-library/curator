# frozen_string_literal: true

module Curator
  class Filestreams::ImageSerializer < Filestreams::FileSetSerializer
    schema_as_json do
      attributes :exemplary_image_of
    end
  end
end
