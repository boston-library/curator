# frozen_string_literal: true

module Curator
  class Engine < ::Rails::Engine
    require 'concurrent'
    require 'delegate'
    require 'forwardable'
    require 'faraday'
    require 'faraday_middleware'
    require 'faraday-http-cache'
    require 'addressable'
    require 'acts_as_list'
    require 'attr_json'
    require 'htmlentities'
    require 'ox'
    require 'oj'
    require 'rsolr'
    require 'singleton'
    require 'traject'
    require 'digest'

    if Rails.env.development? || Rails.env.test?
      begin
        require 'factory_bot_rails'
      rescue LoadError
        puts 'Factory Bot Rails Not installed!'
      end

      # load this here so we can access Dotenv-loaded properties in lib/curator.rb
      require 'dotenv'
      Dotenv.load(".env.#{ENV.fetch('RAILS_ENV', 'development')}", '.env')
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

    config.eager_load_namespaces << Curator

    config.before_initialize do
      Oj.optimize_rails
      Oj.default_options =
      {
        mode: :rails,
        time_format: :ruby,
        hash_class: ActiveSupport::HashWithIndifferentAccess,
        omit_nil: true
      }
      Curator.setup!
    end

    initializer 'inflections' do
      # NOTE: This is needed to prevent 'metadata'.classify from becomming Metadatum
      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.singular 'metadata', 'metadata'
      end
    end

    initializer 'mime_types' do
      Mime::Type.register 'application/marcxml+xml', :marc, %w(application/marc)
      Mime::Type.register 'application/mods+xml', :mods
    end

    initializer 'curator.append_migrations' do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |path|
          app.config.paths['db/migrate'].push(path)
        end
      end
    end
  end
end
