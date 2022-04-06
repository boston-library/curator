# frozen_string_literal: true

require_relative 'builder_helpers'

module Curator
  module Serializers
    module SchemaBuilders
      class XML
        include BuilderHelpers::XMLBuilder
      end
      #
      # module XmlResource
      #
      #
      #   class Element
      #     attr_reader :name, :attributes, :if_block
      #
      #     def initialize(name, attributes = {}, if_block: nil, &block)
      #       @name = name
      #       @attributes = attributes
      #       @if_block = if_block
      #     end
      #   end
      #
      #   class Node
      #   end
      #
      #   module InstanceMethods
      #   end
      #
      #   module ClassMethods
      #     attr_reader(*DSLS.keys)
      #
      #     def inherited(base)
      #       super
      #       BUILDER_DSL.each_key { |name|  base.instance_variable_set("@#{name}", instance_variable_get("@#{name}").clone) }
      #     end
      #
      #     def elements(*names, if: nil)
      #     end
      #
      #     def element(*)
      #     end
      #
      #     def assign_elements(*)
      #     end
      #   end
      # end
    end
  end
end
