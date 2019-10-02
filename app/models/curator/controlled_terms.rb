# frozen_string_literal: true
module Curator
  module ControlledTerms
    extend ActiveSupport::Autoload
    extend Curator::NamespaceAccessor
    def self.table_name_prefix
      'curator_controlled_terms_'
    end

    def self.nomenclature_types
      %w(Genre Geographic Language License Name ResourceType Role Subject).freeze
    end

    autoload_under 'nomenclatures' do
      self.nomenclature_types.each do |nom_type|
        autoload nom_type.to_sym
      end
    end

    namespace_klass_accessor :authority
    namespace_klass_accessor :genre
    namespace_klass_accessor :geographic
    namespace_klass_accessor :language
    namespace_klass_accessor :license
    namespace_klass_accessor :name
    namespace_klass_accessor :resource_type
    namespace_klass_accessor :role
    namespace_klass_accessor :subject
  end
end
