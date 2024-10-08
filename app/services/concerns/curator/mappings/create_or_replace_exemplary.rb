# frozen_string_literal: true

module Curator
  module Mappings::CreateOrReplaceExemplary
    extend ActiveSupport::Concern

    included do
      include InstanceMethods
    end

    module InstanceMethods
      protected

      def create_or_replace_exemplary!(exemplary_file_set_ark_id = nil)
        return if exemplary_file_set_ark_id.blank?

        exemplary_file_set = @record.file_sets.exemplaryable.find_by!(ark_id: exemplary_file_set_ark_id)
        @record.build_exemplary_image_mapping if @record.exemplary_image_mapping.blank?

        @record.exemplary_image_mapping.exemplary_file_set = exemplary_file_set
      rescue ActiveRecord::RecordNotFound => e
        @record.errors.add(:exemplary_file_set, e.message)
        raise ActiveRecord::RecordInvalid, @record
      end
    end
  end
end
