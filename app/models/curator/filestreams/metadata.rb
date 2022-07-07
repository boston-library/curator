# frozen_string_literal: true

module Curator
  class Filestreams::Metadata < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(metadata_ia metadata_ia_scan metadata_marc_xml metadata_mods metadata_oai).freeze

    belongs_to :file_set_of, inverse_of: :metadata_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :metadata_ia
    has_one_attached :metadata_ia_scan
    has_one_attached :metadata_marc_xml
    has_one_attached :metadata_mods
    has_one_attached :metadata_oai

    has_paper_trail

    after_update_commit :set_as_exemplary

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      return super(%i(metadata_oai image_thumbnail_300)) if file_set_of.is_harvested?

      required_derivatives.any? { |a| derivative_attachment_uploaded?(a) }
    end

    def set_as_exemplary
      return unless image_thumbnail_300.uploaded? && file_set_of.exemplary_file_set.blank? && file_set_of.is_harvested?

      exemplary_image_of_mappings.create(exemplary_object: file_set_of)
    end
  end
end
