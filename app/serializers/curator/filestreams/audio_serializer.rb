# frozen_string_literal: true

module Curator
  class Filestreams::AudioSerializer < Filestreams::FileSetSerializer
    schema_as_json do
      attribute(:audio_primary_url) { |record, serializer_params| serializer_params[:show_primary_url].presence ? record.audio_primary&.url : nil }
    end
  end
end
