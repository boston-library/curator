# frozen_string_literal: true

module Curator
  class Filestreams::Audio < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(audio_access characterization).freeze

    belongs_to :file_set_of, inverse_of: :audio_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :audio_primary
    has_one_attached :document_primary

    with_options service: :derivatives do
      has_one_attached :audio_access
      has_one_attached :document_access
      has_one_attached :text_plain
    end

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def avi_params
      return if !audio_primary.attached? && !audio_service.attached?

      return super[:file_stream].merge({ original_ingest_file_path: audio_primary.metadata['ingest_filepath'] }) if audio_primary.attached?

      super[:file_stream].merge({ original_ingest_file_path: audio_service.metadata['ingest_filepath'] })
    end
  end
end
