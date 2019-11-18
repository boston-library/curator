# frozen_string_literal: true

require 'curator/engine'
require 'curator/namespace_accessor'

module Curator
  extend ActiveSupport::Autoload
  include NamespaceAccessor

  class CuratorError < StandardError; end

  eager_autoload do
    autoload :ServiceClass
    autoload :Descriptives
    autoload :Services
  end

  def self.eager_load!
    super
    Curator::Descriptives.eager_load!
    Curator::Services.eager_load!
  end
end
