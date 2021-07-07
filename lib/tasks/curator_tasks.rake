# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :curator do
  desc 'Setup and install database migrations/ run seeds'
  task setup: :environment do
    puts 'Setting Up Curator Environment!'
    puts '............'
    if Rake::Task.task_defined?('app:db:create')
      puts 'Invoking app:db:create...'
      Rake::Task['app:db:create'].invoke
    elsif Rake::Task.task_defined?('db:create')
      puts 'Invoking db:create...'
      Rake::Task['db:create'].invoke
    else
      raise 'app:db:create and db:create rake tasks are not available!'
    end

    puts '............'
    if Rake::Task.task_defined?('app:db:migrate')
      puts 'Invoking app:db:migrate...'
      Rake::Task['app:db:migrate'].invoke
    elsif Rake::Task.task_defined?('db:migrate')
      puts 'Invoking db:migrate...'
      Rake::Task['db:migrate'].invoke
    else
      raise 'app:db:migrate and db:migrate rake tasks are not available!'
    end

    if %w(development staging production).member?(Rails.env)
      # NOTE: Don't seed values for test environment since the suite does that every run
      puts '............'
      if Rake::Task.task_defined?('app:curator:load_seed')
        puts 'Invoking curator:load_seed...'
        Rake::Task['app:curator:load_seed'].invoke
      elsif Rake::Task.task_defined?('curator:load_seed')
        puts 'Invoking curator:load_seed...'
        Rake::Task['curator:load_seed'].invoke
      else
        raise 'app:curator:load_seed and curator:load_seed rake tasks are not available!'
      end
    end
    puts 'Curator Setup Task Complete!'
  end

  desc 'Load and run seed task for default authorities and nomenclatures'
  task load_seed: :environment do
    puts 'Loading Seed For ControlledTerms Authorities and Nomenclatures'
    Curator::Engine.load_seed
    puts 'Default Seed Loaded. Task Complete!'
  end

  desc 'Reindex all objects'
  task reindex_all: :environment do
    puts 'Preparing to reindex all objects...'
    ActiveRecord::Base.connection_pool.with_connection do
      puts 'Reindexing institutions....'
      Curator::Institution.for_reindex_all.find_each do |inst|
        begin
          puts "Adding Institution-#{inst.ark_id} to reindex queue..."
          inst.queue_indexing_job
        rescue StandardError => e
          puts '==============================='
          puts "Failed To queue Institution-#{inst.ark_id}"
          puts "Reason given: #{e.message}"
          puts '==============================='
        end
      end

      puts 'Reindexing collections...'
      Curator::Collection.for_reindex_all.find_each do |col|
        begin
          puts "Adding Collection-#{col.ark_id} to reindex queue..."
          col.queue_indexing_job
        rescue StandardError => e
          puts '==============================='
          puts "Failed To queue Institution-#{col.ark_id}"
          puts "Reason given: #{e.message}"
          puts '==============================='
        end
      end

      puts 'Reindexing digital objects...'
      Curator::DigitalObject.for_reindex_all.find_each do |obj|
        begin
          puts "Adding DigitalObject-#{obj.ark_id} to reindex queue..."
          obj.queue_indexing_job
        rescue StandardError => e
          puts '==============================='
          puts "Failed To queue DigitalObject-#{obj.ark_id}"
          puts "Reason given: #{e.message}"
          puts '==============================='
        end
      end

      puts 'Reindexing file sets...'
      Curator::Filestreams::FileSet.for_reindex_all.find_each do |file_set|
        begin
          puts "Adding FileSet-#{file_set.class.name}-#{file_set.ark_id} to reindex queue"
          file_set.queue_indexing_job
        rescue StandardError => e
          puts '==============================='
          puts "Failed To queue FileSet-#{file_set.ark_id}"
          puts "Reason given: #{e.message}"
          puts '==============================='
        end
      end
    end
    puts 'Reindex Complete!'
  end
end

# rubocop:enable Metrics/BlockLength
