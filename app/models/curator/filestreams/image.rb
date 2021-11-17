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

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      return super(required_derivatives.dup.delete(derivative_source.name.to_sym)) if required_derivatives.include?(derivative_source&.name&.to_sym)

      super(required_derivatives)
    end

    def avi_payload
      return if derivative_source.blank?

      payload = super
      payload[:file_stream][:original_ingest_file_path] = derivative_source.metadata['ingest_filepath']
      payload
    end

    def derivative_source_changed?
      return false if derivative_source.blank?

      return image_primary_blob.changed? if derivative_source.name == 'image_primary'

      image_service_blob.changed?
    end

    protected

    def derivative_source
      return if !image_primary.attached? && !image_service.attached?

      return image_primary if image_primary.attached?

      image_service
    end
  end
end
