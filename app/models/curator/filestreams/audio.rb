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
      return super(required_derivatives.dup.delete(derivative_source.name.to_sym)) if required_derivatives.include?(derivative_source&.name&.to_sym)

      super(required_derivatives)
    end

    def avi_params
      return if derivative_source.blank?

      super[:file_stream].merge({ original_ingest_file_path: derivative_source.metadata['ingest_filepath'] })
    end

    def derivative_source_changed?
      return false if derivative_source.blank?

      return audio_primary_blob.changed? if derivative_source.name == 'audio_primary'

      audio_access_blob.changed?
    end

    protected

    def derivative_source
      return if !audio_primary.attached? && !audio_access.attached?

      return audio_primary if audio_primary.attached?

      audio_access
    end
  end
end
