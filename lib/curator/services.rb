# frozen_string_literal: true

module Curator
  module Services
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Base
      autoload :FactoryService
      autoload :TransactionHandler
      autoload :UpdaterService
    end
  end
end
