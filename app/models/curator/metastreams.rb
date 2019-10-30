# frozen_string_literal: true

module Curator
  module Metastreams
    extend Curator::NamespaceAccessor

    def self.table_name_prefix
      'curator_metastreams_'
    end

    namespace_klass_accessors :administrative, :descriptive, :workflow
  end
end
