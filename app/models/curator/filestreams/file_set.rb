# frozen_string_literal: true
module Curator
  class Filestreams::FileSet < ApplicationRecord
    self.inheritance_column = :file_set_type

    include Curator::Metastreams::Workflowable
    include Curator::Metastreams::Administratable

    belongs_to :file_set_of, inverse_of: :file_sets, class_name: Curator.digital_object_class.to_s
    acts_as_list scope: :file_set_of

    has_many :exemplary_image_mappings, -> { joins(:exemplary).preload(:exemplary) }, inverse_of: :file_set, class_name: Curator.mappings.exemplary_image_class.to_s

    with_options through: :exemplary_image_mappings, source: :exemplary do
      has_many :exemplary_image_collections, source_type: Curator.collection_class.to_s
      has_many :exemplary_image_objects, source_type: Curator.digital_object_class.to_s
    end

    #
    # def exemplary_image_of
    # end

    # def exemplary_image_mappings
    #   %w(image video document).include?(self.file_type) ? super : Curator.mappings.exemplary_image_class.none
    # end #May need to include other file set types Also need to make read only if it does not fall within this type.
  end
end
