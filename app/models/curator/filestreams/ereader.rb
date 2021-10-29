# frozen_string_literal: true

module Curator
  class Filestreams::Ereader < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(ebook_access_epub characterization).freeze

    belongs_to :file_set_of, inverse_of: :ereader_file_sets, class_name: 'Curator::DigitalObject'

    with_options service: :derivatives do
      has_one_attached :ebook_access_epub
      has_one_attached :ebook_access_mobi
      has_one_attached :ebook_access_daisy
    end

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def avi_params
      return if !ebook_access_epub.attached?

      super[:file_stream].merge({
        ebook_access_epub_data: {
          id: ebook_access_epub_blob.key,
          storage: ebook_access_epub_blob.service_name,
          metadata: {
            filename: ebook_access_epub_blob.filename.to_s,
            md5: ebook_access_epub.checksum,
            size: ebook_access_epub_blob.byte_size,
            mime_type: ebook_access_epub.content_type
          }
        }
      })
    end
  end
end
