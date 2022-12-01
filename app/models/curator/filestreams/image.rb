# frozen_string_literal: true

module Curator
  class Filestreams::Image < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(image_service characterization image_access_800 image_thumbnail_300).freeze

    belongs_to :file_set_of, inverse_of: :image_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :image_primary
    has_one_attached :image_negative_primary
    has_one_attached :text_coordinates_primary

    with_options service: :derivatives do
      has_one_attached :document_access
      has_one_attached :image_georectified_primary
      has_one_attached :image_access_800
      has_one_attached :image_service
      has_one_attached :text_plain
      has_one_attached :text_coordinates_access
    end

    after_destroy_commit :invalidate_iiif_cache
    after_update_commit :invalidate_iiif_manifest, if: :saved_change_to_position?

    has_paper_trail skip: %i(lock_version)

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      # return super without image service if image_service if the derivative_source
      return super(required_derivatives.dup.delete_if { |el| el == derivative_source.name.to_sym }) if required_derivatives.include?(derivative_source&.name&.to_sym)

      return super(required_derivatives.dup + %i(text_plain text_coordinates_access)) if text_coordinates_primary.uploaded?

      super(required_derivatives)
    end

    def avi_payload
      return if derivative_source.blank?

      payload = super
      payload[:file_stream][:original_ingest_file_path] = derivative_source.metadata['ingest_filepath']
      if derivative_source.name == 'image_primary' && image_service.uploaded?
        image_primary_data = { derivatives: {} }
        image_primary_data[:derivatives][:image_service] = {
          id: image_service.key,
          storage: "#{image_service.service_name}_store",
          metadata: {
            filename: image_service.filename.to_s,
            md5: image_service.checksum,
            size: image_service.byte_size,
            mime_type: image_service.content_type
          }
        }
        payload[:file_stream][:image_primary_data] = image_primary_data
      end

      return payload if !text_coordinates_primary.uploaded?

      payload[:file_stream][:mets_alto_stream_attributes] = { original_ingest_file_path: text_coordinates_primary.metadata['ingest_filepath'] }
      payload
    end

    def derivative_source_changed?
      return false if derivative_source.blank?

      return image_primary.changed? if derivative_source.name == 'image_primary'

      image_service.changed?
    end

    protected

    def derivative_source
      return if !image_primary.uploaded? && !image_service.uploaded?

      return image_primary if image_primary.uploaded?

      image_service
    end

    def invalidate_iiif_manifest
      Curator::IIIFManifestInvalidateJob.set(wait: 3.seconds).perform_later(file_set_of.ark_id)
    end

    def invalidate_iiif_cache
      Curator::Filestreams::IIIFCacheInvalidateJob.set(wait: 2.seconds).perform_later(ark_id)
    end
  end
end
