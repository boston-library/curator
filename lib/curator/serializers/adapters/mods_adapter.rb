# frozen_string_literal: true

module Curator
  module Serializers
    class ModsAdapter < XMLAdapter
      # Inherited adapter for rendering Content-Type=application/mods+xml data
      def initialize(base_builder_class: Curator::Serializers::SchemaBuilders::Mods, &block)
        super
      end
    end
  end
end
