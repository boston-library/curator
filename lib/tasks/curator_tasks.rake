# frozen_string_literal: true

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
    if Rake::Task.task_defined?('app:active_storage:install')
      puts 'Invoking app:active_storage:install...'
      Rake::Task['app:active_storage:install'].invoke
    elsif Rake::Task.task_defined?('active_storage:install')
      puts 'Invoking app:active_storage:install...'
      Rake::Task['active_storage:install'].invoke
    else
      raise 'app:active_storage:install and active_storage:install rake tasks are not available!'
    end
    puts '............'
    if Rake::Task.task_defined?('app:db:migrate')
      puts 'Invoking app:db:migrate...'
      Rake::Task['app:db:migrate'].invoke
      if Rails.env.development?
        puts 'Invoking app:db:migrate with RAILS_ENV=test'
        system('rails app:db:migrate RAILS_ENV=test')
      end
    elsif Rake::Task.task_defined?('db:migrate')
      puts 'Invoking db:migrate...'
      Rake::Task['db:migrate'].invoke
      if Rails.env.development?
        puts 'Invoking app:db:migrate with RAILS_ENV=test'
        system('rails db:migrate RAILS_ENV=test')
      end
    else
      raise 'app:db:migrate and db:migrate rake tasks are not available!'
    end

    if Rake::Task.task_defined?('app:db:test:prepare')
      puts 'Invoking app:db:test:prepare....'
      Rake::Task['app:db:test:prepare'].invoke
    elsif Rake::Task.task_defined?('db:test:prepare')
      puts 'Invoking db:test:prepare....'
      Rake::Task['db:test:prepare'].invoke
    else
      raise 'app:db:test:prepare and db:test:prepare rake tasks are not available!'
    end

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
    puts 'Curator Setup Task Complete!'
  end

  desc 'Load and run seed task for default authorities and nomenclatures'
  task load_seed: :environment do
    puts 'Loading Seed For ControlledTerms Authorities and Nomenclatures'
    Curator::Engine.load_seed
    puts 'Default Seed Loaded. Task Complete!'
  end
end
