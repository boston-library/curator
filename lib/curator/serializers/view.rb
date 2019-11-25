# frozen_string_literal: true

module Curator
  module Serializers
    class View
      attr_reader :name, :root, :attributes, :links, :nodes, :relations

      def initialize(name, root: nil, attributes: Concurrent::Array.new, links: Concurrent::Array.new, nodes: Concurrent::Array.new, relations: Concurrent::Array.new, meta: Concurrent::Array.new)
        @name = name.to_sym
        @root = root
        @attributes = attributes
        @links = links
        @nodes = nodes
        @relations = relations
      end


      def record_view_hash(record)
      end
    end
  end
end
