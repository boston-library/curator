
require 'faraday'
require 'faraday_middleware'
require 'addressable'
require 'attr_json'
require 'active_model_serializers'

module CommonwealthCurator
  extend ActiveSupport::Autoload

  # eager_autoload do
  #   # autoload :Service, 'commonwealth_curator/service_module'
  #   autoload :Descriptives
  # end
end

require "commonwealth_curator/engine"
