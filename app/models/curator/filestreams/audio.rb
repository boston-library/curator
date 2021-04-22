# frozen_string_literal: true

module Curator
  class Filestreams::Audio < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(audio_access characterization).freeze

    belongs_to :file_set_of, inverse_of: :audio_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :audio_access, service: :derivatives
    has_one_attached :audio_primary
    has_one_attached :document_access, service: :derivatives
    has_one_attached :document_primary
    has_one_attached :text_plain

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def avi_params
      return if !audio_primary.attached?

      super[avi_file_class].merge({
        audio_primary_data: {
          id: audio_primary_blob.key,
          metadata: {
            byte_size: audio_primary_blob.byte_size,
            checksum: audio_primary_blob.checksum,
            file_name: audio_primary_blob.filename.to_s,
            mime_type: audio_primary_blob.content_type.to_s,
          }
        }
      })
    end

  end
end
