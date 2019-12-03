# frozen_string_literal: true

module Curator
  module Serializers
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Adapter
      autoload :SerializedAttr
      autoload :AdapterSchema
      autoload :AbstractSerializer
      autoload_under 'adapters' do
        autoload :NullAdapter
        autoload :JSONAdapter
        autoload :XMLAdapter
      end
      autoload_under 'serialized_attrs' do
        autoload :Attribute
        autoload :Resource
        autoload :NullResource
        autoload :Link
        autoload :Meta
        autoload :Node
        autoload :Relation
        autoload :Collection
      end
    end

  end
end
