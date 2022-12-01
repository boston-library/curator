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

    has_paper_trail skip: %i(lock_version)

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def avi_payload
      return if derivative_source.blank?

      payload = super
      payload[:file_stream][:ebook_access_epub_data] = {
        id: derivative_source.key,
        storage: "#{derivative_source.service_name}_store", # Should be 'derivatives_store'
        metadata: {
          filename: derivative_source.filename.to_s,
          md5: derivative_source.checksum,
          size: derivative_source.byte_size,
          mime_type: derivative_source.content_type
        }
      }
      payload
    end

    def derivative_source_changed?
      return false if derivative_source.blank?

      ebook_access_epub_blob.changed?
    end

    protected

    def derivative_source
      return if !ebook_access_epub.attached?

      ebook_access_epub
    end
  end
end
