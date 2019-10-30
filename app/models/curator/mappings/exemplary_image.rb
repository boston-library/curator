# frozen_string_literal: true

module Curator
  class Mappings::ExemplaryImage < ApplicationRecord
    VALID_EXEMPLARY_OBJECT_TYPES = %w(Collection DigitalObject).freeze
    VALID_EXEMPLARY_FILE_SET_TYPES = %w(Image Document Video).freeze

    belongs_to :exemplary_object, inverse_of: :exemplary_image_mappings, polymorphic: true

    belongs_to :exemplary_file_set, inverse_of: :exemplary_image_of_mappings, polymorphic: true

    validates :exemplary_file_set_id, uniqueness: { scope: [:exemplary_file_set_type, :exemplary_object_type, :exemplary_object_id], allow_nil: true }

    validates :exemplary_object_type, inclusion: {in: VALID_EXEMPLARY_OBJECT_TYPES.collect{|obj_type| "Curator::#{obj_type}"}, allow_nil: true }

    validates :exemplary_file_set_type, inclusion: {in: VALID_EXEMPLARY_FILE_SET_TYPES.collect{|fset_type| "Curator::Filestreams::#{fset_type}"}, allow_nil: true}

    def exemplary_file_set=(exemplary_file_set)
      super
      self.exemplary_file_set_type = exemplary_file_set.class.to_s # prevents the base STI class from being added as the exemplary_file_set_type
    end
  end
end
