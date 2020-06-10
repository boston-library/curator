# frozen_string_literal: true

module Curator
  module Mappings
    module Exemplary
      module Object
        extend ActiveSupport::Concern
        EXEMPLARYABLE_FILE_SETS = Mappings::ExemplaryImage::VALID_EXEMPLARY_FILE_SET_TYPES.map { |exemplary_file_type| "Curator::Filestreams::#{exemplary_file_type}" }.freeze

        included do
          has_one :exemplary_image_mapping, -> { includes(:exemplary_file_set) }, as: :exemplary_object, inverse_of: :exemplary_object, class_name: 'Curator::Mappings::ExemplaryImage', dependent: :destroy, autosave: true

          # delegate :exemplary_file_set, to: :exemplary_image_mapping, allow_nil: true
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
            return self.class.none if exemplary_image_of_collections.blank? && exemplary_image_of_objects.blank?

            collection_sql = exemplary_image_of_collections.select(:id, :ark_id).to_sql.strip
            object_sql = exemplary_image_of_objects.select(:id, :ark_id).to_sql.strip
            union_clause = collection_sql.present? && object_sql.present? ? 'UNION' : ''
            exemplary_clause = <<-SQL.strip_heredoc
                                  #{collection_sql}
                                  #{union_clause}
                                  #{object_sql}
                                SQL

            full_sql_clause = <<-SQL.strip_heredoc
                                  WITH RECURSIVE exemplary_of(ark_id) AS (
                                    SELECT exemplary.ark_id FROM (
                                      #{exemplary_clause}
                                    ) exemplary
                                  ) SELECT ark_id
                                    FROM exemplary_of
                                SQL

            self.class.connection.select_all(full_sql_clause, 'exemplary_image_of', preparable: true).to_a
          end
        end
      end
    end
  end
end
