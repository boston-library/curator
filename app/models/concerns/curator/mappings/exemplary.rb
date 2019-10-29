# frozen_string_literal: true
module Curator
  module Mappings
    module Exemplary
      module ObjectImagable
        extend ActiveSupport::Concern
        included do
          has_many :exemplary_image_mappings, as: :exemplary_object, inverse_of: :exemplary_object, class_name: Curator.mappings.exemplary_image_class_name, dependent: :destroy
        end
      end
      module FileSetImagable
        extend ActiveSupport::Concern
        included do
          has_many :exemplary_image_of_mappings, ->(s) { includes(:exemplary_object).rewhere(exemplary_file_set_type: s.class.to_s) }, as: :exemplary_file_set, inverse_of: :exemplary_file_set, class_name: Curator.mappings.exemplary_image_class_name, dependent: :destroy

          with_options through: :exemplary_image_of_mappings, source: :exemplary_object do
            has_many :exemplary_image_collections, source_type: Curator.collection_class_name
            has_many :exemplary_image_objects, source_type: Curator.digital_object_class_name
          end
        end
      end
    end
  end
end
