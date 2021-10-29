# frozen_string_literal: true

module Curator
  class Filestreams::Video < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(video_access_mp4 characterization).freeze

    belongs_to :file_set_of, inverse_of: :video_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_primary
    has_one_attached :video_primary

    with_options service: :derivatives do
      has_one_attached :document_access
      has_one_attached :text_plain
      has_one_attached :video_access_mp4
      has_one_attached :video_access_webm
    end

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def avi_params
      return if !video_primary.attached? && !video_access_mp4.attached?

      return super[:file_stream].merge({ original_ingest_file_path: video_primary.metadata['ingest_filepath'] }) if video_primary.attached?

      super[:file_stream].merge({ original_ingest_file_path: video_access_mp4.metadata['ingest_filepath'] })
    end
  end
end
