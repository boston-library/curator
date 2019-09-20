# frozen_string_literal: true
module CommonwealthCurator
  module ControlledTerms
    ALLOWED_NOM_TYPES=%w(Genre Geographic Language License Name ResourceType Role Subject).freeze
    def self.table_name_prefix
      'curator_controlled_terms_'
    end
  end
end
