# frozen_string_literal: true

module Curator
  class Filestreams::Text < Filestreams::FileSet
    DEFAULT_REQUIRED_DERIVATIVES = %i(text_plain characterization).freeze

    belongs_to :file_set_of, inverse_of: :text_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :text_plain, service: :derivatives
    has_one_attached :text_coordinates_primary

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def avi_params
      return if derivative_source.blank?

      super[:file_stream].merge({ original_ingest_filepath: derivative_source.metadata['ingest_filepath'] })
    end

    def derivative_source_changed?
      return false if derivative_source.blank?

      text_plain_blob.changed?
    end

    protected

    def derivative_source
      return if !text_plain.attached?

      text_plain
    end
  end
end
