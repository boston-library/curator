# frozen_string_literal: true

module Curator
  class Filestreams::Image < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(image_service characterization image_thumbnail_300).freeze

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
      super(required_derivatives)
    end

    def avi_params
      return if !image_primary.attached?

      super[avi_file_class].merge({
        image_primary_data: {
          id: image_primary_blob.key,
          metadata: {
            byte_size: image_primary_blob.byte_size,
            checksum: image_primary_blob.checksum,
            file_name: image_primary_blob.filename.to_s,
            mime_type: image_primary_blob.content_type.to_s,
          }
        }
      })
    end
  end
end
