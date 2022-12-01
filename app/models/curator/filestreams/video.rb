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

    has_paper_trail skip: %i(lock_version)

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      return super(required_derivatives.dup.delete_if { |el| el == derivative_source.name.to_sym }) if required_derivatives.include?(derivative_source&.name&.to_sym)

      super(required_derivatives)
    end

    def avi_payload
      return if derivative_source.blank?

      payload = super
      payload[:file_stream][:original_ingest_file_path] = derivative_source.metadata['ingest_filepath']
      if derivative_source.name == 'video_primary' && (video_access_mp4.attached? || video_access_webm.attached?)
        video_primary_data = { derivatives: {} }
        if video_access_mp4.attached?
          video_primary_data[:derivatives][:video_access_mp4] = {
            id: video_access_mp4.key,
              storage: "#{video_access_mp4.service_name}_store",
              metadata: {
                filename: video_access_mp4.filename.to_s,
                md5: video_access_mp4.checksum,
                size: video_access_mp4.byte_size,
                mime_type: video_access_mp4.content_type
              }
          }
        end
        if video_access_webm.attached?
          video_primary_data[:derivatives][:video_access_webm] = {
            id: video_access_webm.key,
            storage: "#{video_access_webm.service_name}_store",
            metadata: {
              filename: video_access_webm.filename.to_s,
              md5: video_access_webm.checksum,
              size: video_access_webm.byte_size,
              mime_type: video_access_webm.content_type
            }
          }
        end
        payload[:file_stream][:video_primary_data] = video_primary_data if video_primary_data[:derivatives].present?
      end
      payload
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
