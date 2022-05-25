# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      extend ActiveSupport::Autoload

      eager_autoload do
        autoload :BuilderHelpers
        autoload :JSON
        autoload :XML
        autoload :Mods
      end
    end
  end
end
