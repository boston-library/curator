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
      return super(required_derivatives.dup.delete(:document_access)) if derivative_source.present? && text_plain.attached?

      return super(required_derivatives.dup.delete(derivative_source.name.to_sym)) if required_derivatives.include?(derivative_source&.name&.to_sym)

      super(required_derivatives)
    end

    def avi_params
      return if derivative_source.blank?

      super[avi_file_class].merge({ original_ingest_filepath: derivative_source.metadata['ingest_filepath'] })
    end


    def derivative_source_changed?
      return false if derivative_source.blank?

      return document_primary_blob.changed? if derivative_source.name == 'document_primary'

      document_access_blob.changed?
    end

    protected

    def derivative_source
      return if !document_primary.attached? && !document_access.attached?

      return document_primary if document_primary.attached?

      document_access
    end
  end
end
