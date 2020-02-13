# frozen_string_literal: true

module Curator
  module Mappings
    module Exemplary
      module Object
        extend ActiveSupport::Concern

        included do
          has_one :exemplary_image_mapping, -> { includes(:exemplary_file_set) }, as: :exemplary_object, inverse_of: :exemplary_object, class_name: 'Curator::Mappings::ExemplaryImage', dependent: :destroy

          # delegate :exemplary_file_set, to: :exemplary_image_mapping, allow_nil: true

          # NOTE: no idea why this doesn't work will add a delegator instead seeing how that still works
          has_one :exemplary_file_set, through: :exemplary_image_mapping, source: :exemplary_file_set
        end
      end
      module FileSet
        extend ActiveSupport::Concern
        included do
          has_many :exemplary_image_of_mappings, -> { includes(:exemplary_object) }, inverse_of: :exemplary_file_set, class_name: 'Curator::Mappings::ExemplaryImage', foreign_key: :exemplary_file_set_id, dependent: :destroy

          with_options through: :exemplary_image_of_mappings, source: :exemplary_object do
            has_many :exemplary_image_of_collections, source_type: 'Curator::Collection'
            has_many :exemplary_image_of_objects, source_type: 'Curator::DigitalObject'
          end

          def exemplary_image_of
            exemplary_sql =  <<-SQL.strip
              WITH RECURSIVE exemplary_of(ark_id) AS (
                SELECT exemplary.ark_id FROM (
                  #{exemplary_image_of_collections.select(:id, :ark_id).to_sql}
                  UNION
                  #{exemplary_image_of_objects.select(:id, :ark_id).to_sql}
                ) exemplary
              ) SELECT ark_id
                FROM exemplary_of
            SQL

            self.class.connection.select_all(exemplary_sql, 'exemplary_image_of', preparable: true).to_a
          end
        end
      end
    end
  end
end
