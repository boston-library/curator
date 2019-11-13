# frozen_string_literal: true

module Curator
  class Filestreams::Document < Filestreams::FileSet
    include Filestreams::Characterizable
    include Curator::Mappings::Exemplary::FileSetImagable

    belongs_to :file_set_of, inverse_of: :document_file_sets, class_name: 'Curator::DigitalObject'

    acts_as_list scope: [:file_set_of, :file_set_type], top_of_list: 0

    has_one_attached :document_master
    has_one_attached :document_access
    has_one_attached :image_thumbnail_300
  end
end
