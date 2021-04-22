# frozen_string_literal: true

module Curator
  class Filestreams::Document < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(document_access characterization image_thumbnail_300).freeze

    belongs_to :file_set_of, inverse_of: :document_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_primary
    has_one_attached :document_access, service: :derivatives

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def avi_params
      return if !document_primary.attached?

      super[avi_file_class].merge({
        document_primary_data: {
          id: document_primary_blob.key,
          metadata: {
            byte_size: document_primary_blob.byte_size,
            checksum: document_primary_blob.checksum,
            file_name: document_primary_blob.filename.to_s,
            mime_type: document_primary_blob.content_type.to_s,
          }
        }
      })
    end
  end
end
