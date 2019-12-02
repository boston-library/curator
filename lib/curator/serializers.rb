# frozen_string_literal: true

module Curator
  module Serializers
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :AbstractSerializer
      autoload :AdapterMap
      autoload :Adapter
      autoload_under 'adapters' do
        autoload :NullAdapter
        autoload :JSON
        autoload :XML
      end
    end
  end
end
