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
      return if !text_plain.attached?

      super[avi_file_class].merge({
        text_plain_data: {
          id: text_plain_blob.key,
          metadata: {
            byte_size: text_plain_blob.byte_size,
            checksum: text_plain_blob.checksum,
            file_name: text_plain_blob.filename.to_s,
            mime_type: text_plain_blob.content_type.to_s,
          }
        }
      })
    end
  end
end
