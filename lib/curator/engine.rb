# frozen_string_literal: true
module Curator
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.orm :active_record
      g.api_only = true
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    isolate_namespace Curator
    engine_name 'curator'

    if %w(development test).freeze.include?(ENV.fetch('RAILS_ENV', 'development'))
      begin
        require 'factory_bot_rails'
      rescue LoadError
        puts "Factory Bot Rails Not installed!"
      end
      if defined?(FactoryBotRails)
        config.factory_bot.definition_file_paths << File.expand_path('../../spec/factories/curator', __dir__)
      end
    end

    config.to_prepare do
      Curator.init_namespace_accessors
    end

    initializer 'curator.rails_requires' do
      require 'acts_as_list'
      require 'attr_json'
      require 'active_model_serializers'
      require 'oj'
    end

    initializer 'curator.append_migrations' do |app|
      config.paths['db/migrate'].expanded.each do |path|
        app.config.paths['db/migrate'].push(path)
      end
    end

    config.after_initialize do
      Oj.optimize_rails
      ActiveModel::Serializer.config.adapter = :json
    end
  end
end
