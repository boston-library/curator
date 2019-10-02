# frozen_string_literal: true
module Curator
  module Metastreams
    extend Curator::NamespaceAccessor
    def self.table_name_prefix
      'curator_metastreams_'
    end

    namespace_klass_accessor :administrative
    namespace_klass_accessor :descriptive
    namespace_klass_accessor :workflow
  end
end
