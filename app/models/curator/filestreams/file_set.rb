# frozen_string_literal: true
module Curator
  class Filestreams::FileSet < ApplicationRecord
    self.inheritance_column = :file_set_type

    include Curator::Mintable
    include Curator::Metastreams::Workflowable
    include Curator::Metastreams::Administratable

    has_one_attached :metadata_foxml

    validates :file_set_type, presence: true, inclusion: { in: Filestreams.file_set_types.collect{|type| "Curator::Filestreams::#{type}"} }
    #
    # def exemplary_image_of
    # end

    # def exemplary_image_mappings
    #   %w(image video document).include?(self.file_type) ? super : Curator.mappings.exemplary_image_class.none
    # end #May need to include other file set types Also need to make read only if it does not fall within this type.
  end
end
