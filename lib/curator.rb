# frozen_string_literal: true

# Core dependencies
require 'aasm'
require 'activerecord/postgres_enum'
require 'after_commit_everywhere'
require 'alba'
require 'concurrent'
require 'connection_pool'
require 'delegate'
require 'forwardable'
require 'http'
require 'down/http'
require 'addressable'
require 'acts_as_list'
require 'attr_json'
require 'htmlentities'
require 'faraday'
require 'mime/types'
require 'nokogiri'
require 'oj'
require 'ox'
require 'paper_trail'
require 'paper_trail-association_tracking'
require 'rsolr'
require 'singleton'
require 'traject'
require 'digest'

# Curator specific files
require 'curator/engine'
require 'curator/namespace_accessor'
require 'curator/indexable_settings'
require 'curator/configuration'
require 'curator/version'

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
