# frozen_string_literal: true

module Curator
  class Engine < ::Rails::Engine
    require 'aasm'
    require 'activerecord/postgres_enum'
    require 'after_commit_everywhere'
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
    require 'mime/types'
    require 'ox'
    require 'oj'
    require 'paper_trail'
    require 'paper_trail-association_tracking'
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
      PaperTrail.config.track_associations = true
      PaperTrail.config.has_paper_trail_defaults = { on: %i(update destroy touch) }
      Curator.setup!
    end

    initializer 'curator.inflections' do
      # NOTE: This is needed to prevent 'metadata'.classify from becomming Metadatum
      # NOTE: Also needed for underscore method in the filestream Attacher concern
      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.singular 'metadata', 'metadata'
        inflect.acronym '300'
        inflect.acronym '800'
      end
    end

    initializer 'curator.mime_types' do
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
