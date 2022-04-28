# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      class XML
        # This is the base class for serializingdata in XML. See the XMLBuilder module in ./builder_helpers.rb for details on DSL methods  
        include BuilderHelpers::XMLBuilder
      end
    end
  end
end
