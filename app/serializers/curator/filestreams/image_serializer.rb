# frozen_string_literal: true

module Curator
  class Filestreams::ImageSerializer < Filestreams::FileSetSerializer
    build_schema_as_json do
      attributes :exemplary_image_of

      attribute :image_primary_url do |record|
        params[:show_primary_url].presence ? record.image_primary&.url : nil
      end
    end
  end
end
