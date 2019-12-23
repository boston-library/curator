# frozen_string_literal: true

module Curator
  module Parsers
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :InputParser
      autoload :Constants
      autoload :EdtfDateParser
    end
  end
end
