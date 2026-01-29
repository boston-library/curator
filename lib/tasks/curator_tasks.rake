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
    puts 'Doing health check...'
    reindex_all_health_check!

    puts 'Preparing to reindex all objects...'

    reindex_record = lambda { |record|
      begin
        record.update_index
      rescue StandardError => e
        output_reindex_errors(e, record)
      end
    }

    reindex_all_with_batching do
      puts "Reindexing #{Curator::Institution.count} institutions...."
      Curator::Institution.for_reindex_all.find_each(&reindex_record)

      puts "Reindexing #{Curator::Collection.count} collections..."
      Curator::Collection.for_reindex_all.find_each(&reindex_record)

      puts "Reindexing #{Curator::DigitalObject.count} digital_objects..."
      Curator::DigitalObject.for_reindex_all.find_each(&reindex_record)

      puts "Reindexing #{Curator::Filestreams::FileSet.count} file_sets..."
      Curator::Filestreams::FileSet.for_reindex_all.find_each(&reindex_record)
    end
    puts 'Reindex Complete!'
  end
end

def output_reindex_errors(e, item)
  puts '==============================='
  puts "Failed To reindex #{item.class.name}-#{item.ark_id}"
  puts "Reason given: #{e.message}"
  puts '==============================='
end

def reindex_all_health_check!
  Curator::Indexable.indexer_health_check!
rescue Curator::Exceptions::SolrUnavailable, Curator::Exceptions::AuthorityApiUnavailable => e
  raise e.message
end

# NOTE: per this comment https://github.com/sciencehistory/kithe/blob/56a65a97292c3d0e273a822080df6d1db8616cfa/app/indexing/kithe/indexable.rb#L57
# If we are updating a batch of record in a call back without a background job we should wrap in the index_with batching: true

def reindex_all_with_batching
  Curator::Indexable.index_with(batching: true) do
    ActiveRecord::Base.with_connection do
      yield
    end
  end
end

# rubocop:enable Metrics/BlockLength
