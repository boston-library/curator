# frozen_string_literal: true

module Curator
  class Mappings::ExemplaryImage < ApplicationRecord
    VALID_EXEMPLARY_OBJECT_TYPES = %w(Collection DigitalObject).freeze
    VALID_EXEMPLARY_FILE_SET_TYPES = %w(Image Document Video Metadata).freeze

    belongs_to :exemplary_object, inverse_of: :exemplary_image_mapping, polymorphic: true

    belongs_to :exemplary_file_set, inverse_of: :exemplary_image_of_mappings, class_name: 'Curator::Filestreams::FileSet', touch: true

    validates :exemplary_object_type, uniqueness: { scope: [:exemplary_object_id] },
              inclusion: { in: VALID_EXEMPLARY_OBJECT_TYPES.collect { |obj_type| "Curator::#{obj_type}" } }, on: :create

    validates :exemplary_file_set_id, uniqueness: { scope: [:exemplary_object_id, :exemplary_object_type] }

    validate :exemplary_file_set_class_name_validator, on: :create

    private

    def exemplary_file_set_class_name_validator
      valid_class_names = VALID_EXEMPLARY_FILE_SET_TYPES.collect { |klass| "Curator::Filestreams::#{klass}" }
      exemp_class_name = exemplary_file_set&.class&.name
      errors.add(:exemplary_file_set, "#{exemp_class_name} is not valid!") if !valid_class_names.include?(exemp_class_name)
    end
  end
end
