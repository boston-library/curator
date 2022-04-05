# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      extend ActiveSupport::Autoload

      eager_autoload do
        autoload :JSON
        autoload :XML
      end
    end
  end
end
