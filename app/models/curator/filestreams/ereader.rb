# frozen_string_literal: true

module Curator
  class Filestreams::Ereader < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(ebook_access_epub characterization).freeze

    belongs_to :file_set_of, inverse_of: :ereader_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :ebook_access_epub
    has_one_attached :ebook_access_mobi
    has_one_attached :ebook_access_daisy

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end
  end
end
