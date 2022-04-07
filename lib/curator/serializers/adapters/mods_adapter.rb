# frozen_string_literal: true

module Curator
  module Serializers
    class ModsAdapter < XMLAdapter
      def initialize(base_builder_class: Curator::Serializers::SchemaBuilders::Mods, &block)
        super
      end
    end
  end
end
