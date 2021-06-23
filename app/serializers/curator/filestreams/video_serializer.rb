# frozen_string_literal: true

module Curator
  class Filestreams::VideoSerializer < Filestreams::FileSetSerializer
    schema_as_json do
      attributes :exemplary_image_of
      attribute(:video_primary_url) { |record, serializer_params| serializer_params[:show_primary_url].presence ? record.video_primary&.url : nil }
    end
  end
end
