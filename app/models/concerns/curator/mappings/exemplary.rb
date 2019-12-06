# frozen_string_literal: true

module Curator
  module Mappings
    module Exemplary
      module ObjectImagable
        extend ActiveSupport::Concern
        included do
          has_one :exemplary_image_mappings, as: :exemplary_object, inverse_of: :exemplary_object, class_name: 'Curator::Mappings::ExemplaryImage', dependent: :destroy
        end

        def exemplary_file_set
          exemplary_image_mappings.presence&.exemplary_file_set
        end
      end
      module FileSetImagable
        extend ActiveSupport::Concern
        included do
          has_many :exemplary_image_of_mappings, ->(s) { includes(:exemplary_object).rewhere(exemplary_file_set_type: s.class.to_s) }, as: :exemplary_file_set, inverse_of: :exemplary_file_set, class_name: 'Curator::Mappings::ExemplaryImage', dependent: :destroy

          with_options through: :exemplary_image_of_mappings, source: :exemplary_object do
            has_many :exemplary_image_collections, source_type: 'Curator::Collection'
            has_many :exemplary_image_objects, source_type: 'Curator::DigitalObject'
          end
        end
      end
    end
  end
end
