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

    has_paper_trail skip: %i(lock_version)

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      return super(required_derivatives.dup.delete_if { |el| el == derivative_source.name.to_sym }) if required_derivatives.include?(derivative_source&.name&.to_sym)

      super(required_derivatives)
    end

    def avi_payload
      return if derivative_source.blank?

      payload = super
      payload[:file_stream][:original_ingest_file_path] = derivative_source.metadata['ingest_filepath']
      if derivative_source.name == 'audio_primary' && audio_access.attached?
        payload[:file_stream][:audio_primary_data] = {
          derivatives: {
            audio_access: {
              id: audio_access.key,
              storage: "#{audio_access.service_name}_store",
              metadata: {
                filename: audio_access.filename.to_s,
                md5: audio_access.checksum,
                size: audio_access.byte_size,
                mime_type: audio_access.content_type
              }
            }
          }
        }
      end
      payload
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
