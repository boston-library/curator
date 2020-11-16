# frozen_string_literal: true

module Curator
  class Filestreams::Metadata < Filestreams::FileSet
    include Filestreams::Thumbnailable
    belongs_to :file_set_of, inverse_of: :metadata_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :metadata_ia
    has_one_attached :metadata_ia_scan
    has_one_attached :metadata_marc_xml
    has_one_attached :metadata_mods
    has_one_attached :metadata_oai

    def derivatives_complete?
      #All derivatives for this fileset type are attached?
      true
    end
  end
end
