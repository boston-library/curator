# frozen_string_literal: true
require 'faraday'
require 'faraday_middleware'
require 'addressable'

require 'curator/engine'
require 'curator/namespace_accessor'

module Curator
  extend ActiveSupport::Autoload
  include NamespaceAccessor
  class CuratorError < StandardError; end

  eager_autoload do
    autoload :ServiceClass
    autoload :Descriptives
  end

  def self.eager_load!
    super
    Curator::Descriptives.eager_load!
  end
end
