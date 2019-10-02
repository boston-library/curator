# frozen_string_literal: true
module Curator
  class Filestreams::Image < Filestreams::FileSet
    include Filestreams::Characterizable

    belongs_to :file_set_of, inverse_of: :image_file_sets, class_name: Curator.digital_object_class_name

    acts_as_list scope: [:file_set_of, :file_set_type]

    has_many :exemplary_image_mappings, -> { joins(:exemplary).preload(:exemplary) }, inverse_of: :file_set, class_name: Curator.mappings.exemplary_image_class_name

    with_options through: :exemplary_image_mappings, source: :exemplary do
      has_many :exemplary_image_collections, source_type: Curator.collection_class_name
      has_many :exemplary_image_objects, source_type: Curator.digital_object_class_name
    end

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
