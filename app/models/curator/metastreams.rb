# frozen_string_literal: true

module Curator
  module Metastreams
    extend Curator::NamespaceAccessor

    def self.table_name_prefix
      'curator_metastreams_'
    end

    def self.valid_base_types
      %w(Institution Collection DigitalObject).collect { |base_type| "Curator::#{base_type}" }.freeze
    end

    def self.valid_filestream_types
      Curator::Filestreams.file_set_types.collect { |fstream_type| "Curator::Filestreams::#{fstream_type}" }.freeze
    end

    namespace_klass_accessors :administrative, :descriptive, :workflow
  end
end
