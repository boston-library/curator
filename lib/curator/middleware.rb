# frozen_string_literal: true

module Curator
  module Middleware
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :ArkOrIdConstraint
      autoload :StiTypesConstraint
      autoload :RootApp
    end
  end
end
