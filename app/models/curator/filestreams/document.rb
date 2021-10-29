# frozen_string_literal: true

module Curator
  class Filestreams::Document < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(document_access characterization image_thumbnail_300).freeze

    belongs_to :file_set_of, inverse_of: :document_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_primary

    with_options service: :derivatives do
      has_one_attached :document_access
      has_one_attached :text_plain
    end

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      return super(%i(characterization image_thumbnail_300)) if text_plain.attached? && %i(document_access document_primary).any? { |a| public_send(a).attached? }

      super(required_derivatives)
    end

    def avi_params
      return if !document_primary.attached? && !document_access.attached?

      return super[avi_file_class].merge({ original_ingest_filepath: document_primary.metadata['ingest_filepath'] }) if document_primary.attached?

      super[avi_file_class].merge({ original_ingest_filepath: document_access.metadata['ingest_filepath'] })
    end
  end
end
