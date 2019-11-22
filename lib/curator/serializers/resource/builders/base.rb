# frozen_string_literal: true

module Curator
  module Serializer
    module Builder

      class Base
        attr_reader :name, :attributes, :relations, :nodes, :links

        def initialize(view_name = :default, *args, &block)
          @name = "#{name}".freeze
          @attributes = Concurrent::Array.new
          @relations = Concurrent::Array.new
          @nodes = Concurrent::Array.new
          @links = Concurrent::Array.new
        end


        def serializable_hash
        end
      end
    end
  end
end
