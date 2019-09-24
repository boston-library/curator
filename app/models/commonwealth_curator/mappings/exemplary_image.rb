# frozen_string_literal: true
module CommonwealthCurator
  class Mappings::ExemplaryImage < ApplicationRecord
    VALID_EXEMPLARY_IMAGE_TYPES=%w(Collection DigitalObject)

    belongs_to :exemplary, inverse_of: :exemplary_image_mappings, polymorphic: true

    belongs_to :file_set, inverse_of: :exemplary_image_mappings, class_name: 'CommonwealthCurator::Filestreams::FileSet'

    validates :exemplary_image_of_type, inclusion: {in: VALID_EXEMPLARY_IMAGE_TYPES.collect{|type| "CommonwealthCurator::#{type}"}, allow_nil: true }

    validates :file_set_id, uniqueness: {scope: [:exemplary_image_of_type, :exemplary_image_of_id], allow_nil: true }
  end
end
