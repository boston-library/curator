# frozen_string_literal: true
module Curator
  module Filestreams
    extend Curator::NamespaceAccessor

    def self.table_name_prefix
      'curator_filestreams_'
    end

    def self.file_set_types
      %w(Image Ereader Document Text Metadata Audio Video).freeze
    end

    namespace_klass_accessors *file_set_types.map(&:underscore)
  end
end
