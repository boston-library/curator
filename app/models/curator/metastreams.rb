# frozen_string_literal: true

module Curator
  module Metastreams
    extend Curator::NamespaceAccessor

    def self.table_name_prefix
      'curator.metastreams_'
    end

    def self.valid_base_types
      %w(Institution Collection DigitalObject).collect { |base_type| "Curator::#{base_type}" }.freeze
    end

    def self.valid_filestream_types
      Array.wrap('Curator::Filestreams::FileSet').freeze
    end

    namespace_klass_accessors :administrative, :descriptive, :workflow
  end
end
