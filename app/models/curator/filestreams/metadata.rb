# frozen_string_literal: true

module Curator
  class Filestreams::Metadata < Filestreams::FileSet
    belongs_to :file_set_of, inverse_of: :metadata_file_sets, class_name: 'Curator::DigitalObject'

    acts_as_list scope: [:file_set_of, :file_set_type], top_of_list: 0

    has_one_attached :metadata_ia
    has_one_attached :metadata_ia_scan
    has_one_attached :metadata_marc_xml
    has_one_attached :metadata_mods
    has_one_attached :metadata_oai
    has_one_attached :image_thumbnail_300
  end
end
