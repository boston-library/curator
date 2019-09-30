# frozen_string_literal: true
module Curator
  module ControlledTerms
    def self.table_name_prefix
      'curator_controlled_terms_'
    end

    def self.nomenclature_types
      ControlledTerms::Nomenclature::ALLOWED_NOM_TYPES
    end
  end
end
