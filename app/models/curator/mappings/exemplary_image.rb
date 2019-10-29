# frozen_string_literal: true
module Curator
  class Mappings::ExemplaryImage < ApplicationRecord
    VALID_EXEMPLARY_IMAGE_TYPES = %w(Collection DigitalObject)
    VALID_FILE_SET_TYPES = %w(Image Document Video)

    belongs_to :exemplary, inverse_of: :exemplary_image_mappings, polymorphic: true

    belongs_to :file_set, inverse_of: :exemplary_image_mappings, class_name: Curator.filestreams.image_class_name

    validates :exemplary_type, inclusion: {in: VALID_EXEMPLARY_IMAGE_TYPES.collect{|type| "Curator::#{type}"}, allow_nil: true }

    validates :file_set_id, uniqueness: {scope: [:exemplary_type, :exemplary_id], allow_nil: true }

    validate :validate_file_set_type, if: proc {|ei| ei.file_set.present? }

    private
    def validate_file_set_type
      self.errors.add(:file_set, "file_set_type is not Image, Document, or Video!") unless VALID_FILE_SET_TYPES.include?(self.file_set.class.name.demodulize)
    end
  end
end
