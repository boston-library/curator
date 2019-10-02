# frozen_string_literal: true
module Curator
  module Mappings
    extend Curator::NamespaceAccessor
    def self.table_name_prefix
      'curator_mappings_'
    end

    namespace_klass_accessor :collection_member
    namespace_klass_accessor :desc_host_collection
    namespace_klass_accessor :desc_name_role
    namespace_klass_accessor :desc_term
    namespace_klass_accessor :exemplary_image
    namespace_klass_accessor :host_collection
  end
end
