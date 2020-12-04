# frozen_string_literal: true

module Curator
  module ControlledTerms
    extend Curator::NamespaceAccessor
    def self.table_name_prefix
      'curator_controlled_terms_'
    end

    def self.nomenclature_types
      %w(Genre Geographic Language License Name ResourceType RightsStatement Role Subject).freeze
    end

    namespace_klass_accessors(*nomenclature_types.map(&:underscore).map(&:to_sym).push(:authority))
  end
end
