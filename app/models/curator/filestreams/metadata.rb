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

    def derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      required_derivatives.any? { |a| public_send(a).attached? }
    end
  end
end
