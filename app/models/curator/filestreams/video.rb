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
      return super(required_derivatives.dup.delete(derivative_source.name.to_sym)) if required_derivatives.include?(derivative_source&.name&.to_sym)

      super(required_derivatives)
    end

    def avi_params
      return if derivative_source.blank?

      super[:file_stream].merge({ original_ingest_file_path: derivative_source.metadata['ingest_filepath'] })
    end

    def derivative_source_changed?
      return false if derivative_source.blank?

      return video_primary_blob.changed? if derivative_source.name == 'video_primary'

      video_access_mp4.changed?
    end

    protected

    def derivative_source
      return if !video_primary.attached? && !video_access_mp4.attached?

      return video_primary if video_primary.attached?

      video_access_mp4
    end
  end
end
