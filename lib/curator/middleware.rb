# frozen_string_literal: true

module Curator
  module Middleware
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :ArkOrIdConstraint
      autoload :StiTypesConstraint
      autoload :RootApp
      autoload :RouteConsts
    end
  end
end
