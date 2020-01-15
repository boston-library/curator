# frozen_string_literal: true

module Curator
  class Filestreams::Image < Filestreams::FileSet
    include Curator::Mappings::Exemplary::FileSetImagable

    belongs_to :file_set_of, inverse_of: :image_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_access
    has_one_attached :image_master
    has_one_attached :image_negative_master
    has_one_attached :image_georectified_master
    has_one_attached :image_access_800
    has_one_attached :image_service
    has_one_attached :image_thumbnail_300

    has_one_attached :text_coordinates_master
    has_one_attached :text_coordinates_access

    has_one_attached :text_plain
  end
end
