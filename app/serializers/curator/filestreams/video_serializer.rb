# frozen_string_literal: true

module Curator
  class Filestreams::VideoSerializer < Filestreams::FileSetSerializer
    build_schema_as_json do
      attributes :exemplary_image_of

      attribute :video_primary_url do |resource|
        params[:show_primary_url].presence ? resource.video_primary&.url : nil
      end
    end
  end
end
