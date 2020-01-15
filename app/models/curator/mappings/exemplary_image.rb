# frozen_string_literal: true

module Curator
  class Mappings::ExemplaryImage < ApplicationRecord
    VALID_EXEMPLARY_OBJECT_TYPES = %w(Collection DigitalObject).freeze
    VALID_EXEMPLARY_FILE_SET_TYPES = %w(Image Document Video).freeze

    belongs_to :exemplary_object, inverse_of: :exemplary_image_mapping, polymorphic: true

    belongs_to :exemplary_file_set, inverse_of: :exemplary_image_of_mappings, polymorphic: true

    validates :exemplary_object_type, uniqueness: { scope: :exemplary_object_id }, inclusion: { in: VALID_EXEMPLARY_OBJECT_TYPES.collect { |obj_type| "Curator::#{obj_type}" } }, on: :create

    validates :exemplary_file_set_type, uniqueness: { scope: [:exemplary_file_set_id, :exemplary_object_type, :exemplary_object_id] }, inclusion: { in: VALID_EXEMPLARY_FILE_SET_TYPES.collect { |fset_type| "Curator::Filestreams::#{fset_type}" } }, on: :create

    def exemplary_file_set=(exemplary_file_set)
      super
      self.exemplary_file_set_type = exemplary_file_set.class.name # prevents the base STI class from being added as the exemplary_file_set_type
    end
  end
end
