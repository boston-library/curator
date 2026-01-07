# frozen_string_literal: true

module Curator
  class Engine < ::Rails::Engine
    isolate_namespace Curator
    engine_name 'curator'

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
      Alba.backend = :oj_rails
      PaperTrail.config.version_limit = 5
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
        inflect.acronym 'IIIF'
      end
    end

    initializer 'curator.mime_types' do
      Mime::Type.register 'application/marcxml+xml', :marc, %w(application/marc)
      Mime::Type.register 'application/mods+xml', :mods
    end

    initializer 'curator.active_storage_table_names' do |app|
      app.reloader.to_prepare do
        ActiveStorage::Attached::One.send(:include, Curator::ActiveStorageExtensions::AttachedOneUploaded)

        ActiveSupport.on_load(:active_storage_variant_record) do
          self.table_name = 'curator.active_storage_variant_records'
        end

        ActiveSupport.on_load(:active_storage_blob) do
          self.table_name = 'curator.active_storage_blobs'
          include Curator::ActiveStorageExtensions::BlobUploaded
        end

        ActiveSupport.on_load(:active_storage_attachment) do
          self.table_name = 'curator.active_storage_attachments'
          include Curator::ActiveStorageExtensions::AttachmentUploaded
        end
      end
    end

    initializer 'curator.active_storage_job_override' do |app|
      app.reloader.to_prepare do
        ActiveSupport.on_load(:active_job) do
          ActiveStorage::BaseJob.send(:include, Curator::RetryOnFaradayException)
        end
      end
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
