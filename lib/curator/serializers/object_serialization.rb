# frozen_string_literal: true

module Curator
  module Serializers
    module ObjectSerialization
      extend ActiveSupport::Concern

      included do
        class << self
          attr_reader :_serialization_for_json, :_serialization_for_xml
        end
      end

      class_methods do
        def inherited(subclass)
           subclass.instance_variable_set(:@_serialization_for_xml, Serializers::ViewMap.new )
           subclass.instance_variable_set(:@_serialization_for_json, Serializers.ViewMap.new )
         end

         def json_build(name:, options: {}, &block)
           
         end

         def xml_build(name:, options: {}, &block)
         end
       end
    end
  end
end
