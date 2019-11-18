# frozen_string_literal: true

module Curator
  class Engine < ::Rails::Engine
    require 'faraday'
    require 'faraday_middleware'
    require 'faraday-http-cache'
    require 'addressable'

    require 'acts_as_list'
    require 'attr_json'
    require 'active_model_serializers'
    require 'oj'

    if Rails.env.development? || Rails.env.test?
      begin
        require 'factory_bot_rails'
      rescue LoadError
        puts 'Factory Bot Rails Not installed!'
      end
    end

    isolate_namespace Curator
    engine_name 'curator'
    config.generators do |g|
      g.orm :active_record
      g.api_only = true
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
    config.factory_bot.definition_file_paths << File.expand_path('../../spec/factories/curator', __dir__) if defined?(FactoryBotRails)

    config.to_prepare do
      Dir.glob("#{Curator::Engine.root.join('app', 'models', 'curator', 'descriptives', 'field_sets')}/*.rb").each { |c| require_dependency(c) }
    end

    initializer 'curator.append_migrations' do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |path|
          app.config.paths['db/migrate'].push(path)
        end
      end
    end

    config.after_initialize do
      Curator.init_namespace_accessors
      Oj.optimize_rails
      ActiveModel::Serializer.config.adapter = :json
    end
  end
end
