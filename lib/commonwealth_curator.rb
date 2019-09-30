# frozen_string_literal: true
require 'faraday'
require 'faraday_middleware'
require 'addressable'
require 'attr_json'
require 'active_model_serializers'

require 'commonwealth_curator/engine'
require 'commonwealth_curator/namespace_accessor'

module CommonwealthCurator
  extend ActiveSupport::Autoload
  include NamespaceAccessor
  class CuratorError < StandardError; end

  eager_autoload do
    autoload :CuratorService
    autoload :Descriptives
  end

  def self.eager_load!
    super
    CommonwealthCurator::Descriptives.eager_load!
  end
end
