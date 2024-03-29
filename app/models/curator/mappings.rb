# frozen_string_literal: true

module Curator
  module Mappings
    extend Curator::NamespaceAccessor
    def self.table_name_prefix
      'curator.mappings_'
    end

    namespace_klass_accessors :collection_member, :desc_name_role, :desc_host_collection, :desc_term, :exemplary_image, :host_collection
  end
end
