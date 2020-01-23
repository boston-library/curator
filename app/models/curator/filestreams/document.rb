# frozen_string_literal: true

module Curator
  class Filestreams::Document < Filestreams::FileSet
    belongs_to :file_set_of, inverse_of: :document_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_master
    has_one_attached :document_access
    has_one_attached :image_thumbnail_300
  end
end
