# frozen_string_literal: true

require 'curator/engine'
require 'curator/namespace_accessor'
require 'curator/indexable_settings'
require 'curator/configuration'

module Curator
  extend ActiveSupport::Autoload
  include NamespaceAccessor

  eager_autoload do
    autoload :Decorators
    autoload :Exceptions
    autoload :Middleware
    autoload :Services
    autoload :Parsers
    autoload :Serializers
  end

  def self.eager_load!
    super
    Curator::Decorators.eager_load!
    Curator::Exceptions.eager_load!
    Curator::Middleware.eager_load!
    Curator::Parsers.eager_load!
    Curator::Services.eager_load!
    Curator::Serializers.eager_load!
  end

  def self.setup!
    init_namespace_accessors!
    Curator::Serializers.setup!
  end

  def self.config(&block)
    @config ||= Curator::Configuration.new
    yield @config if block
    @config
  end
end
