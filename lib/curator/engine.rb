# frozen_string_literal: true
module Curator
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.orm :active_record
      g.api_only = true
      g.test_framework :rspec, :fixture => false
    end

    isolate_namespace Curator
    engine_name 'curator'

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
    end

  end
end
