# frozen_string_literal: true
module CommonwealthCurator
  class Engine < ::Rails::Engine

    config.generators do |g|
      g.orm :active_record
      g.api_only = true
      g.test_framework :rspec, :fixture => false
    end

    isolate_namespace CommonwealthCurator
    engine_name 'commonwealth_curator'

    # config.eager_load_namespaces << CommonwealthCurator

    initializer 'commonwealth_curator.append_migrations' do |app|
      config.paths['db/migrate'].expanded.each do |path|
        app.config.paths['db/migrate'].push(path)
      end
    end

    config.after_initialize do
      require 'oj'
      Oj.optimize_rails
    end

  end
end
