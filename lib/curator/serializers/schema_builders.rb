# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      extend ActiveSupport::Autoload

      eager_autoload do
        autoload :JSON
      end
    end
  end
end
