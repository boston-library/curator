# frozen_string_literal: true

module Curator
  module Serializers
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Resource
    end

  end
end
