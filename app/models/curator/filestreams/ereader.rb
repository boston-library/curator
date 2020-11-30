# frozen_string_literal: true

module Curator
  class Filestreams::Ereader < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(ebook_access characterization).freeze

    belongs_to :file_set_of, inverse_of: :ereader_file_sets, class_name: 'Curator::DigitalObject'

    has_many_attached :ebook_access

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end
  end
end
