# frozen_string_literal: true

module Curator
  module Serializers
    extend ActiveSupport::Autoload

    CACHE_KEY_PREFIX = 'curator-serializers'.freeze
    VALID_FORMAT_KEYS=%i(json xml all).freeze

  end
end
