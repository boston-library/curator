# frozen_string_literal: true

module Curator
  class Mappings::DescTerm < ApplicationRecord
    VALID_TERM_CLASSES = Curator::ControlledTerms.nomenclature_types.collect do |klass|
      "Curator::ControlledTerms::#{klass}" unless klass == 'License' || klass == 'RightsStatement'
    end.compact.freeze

    belongs_to :descriptive, inverse_of: :desc_terms, class_name: 'Curator::Metastreams::Descriptive'

    belongs_to :mapped_term, inverse_of: :desc_terms, class_name: 'Curator::ControlledTerms::Nomenclature'

    validates :descriptive_id, uniqueness: { scope: :mapped_term_id }, on: :create

    validate :mapped_term_class_name_validator, on: :create

    private

    def mapped_term_class_name_validator
      term_class_name = mapped_term&.class&.name
      errors.add(:mapped_term, "#{term_class_name} is not valid!") if !VALID_TERM_CLASSES.include?(term_class_name)
    end
  end
end
