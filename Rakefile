# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Curator'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path('spec/internal/Rakefile', __dir__)
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'

require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rails'
  task.requires << 'rubocop-rspec'
  task.requires << 'rubocop-performance'
  task.fail_on_error = true
  # WARNING: Make sure the bottom 3 lines are always commented out before committing
  # task.options << '--safe-auto-correct'
  # task.options << '--disable-uncorrectable'
  # task.options << '-d'
end

Dir.glob('lib/tasks/*.rake').each { |r| import r }

require 'solr_wrapper/rake_task'

desc 'Lint, set up test app, spin up Solr, and run specs'
task ci: [:rubocop] do
  ENV['CI'] = true
  puts 'running continuous integration'
  Rails.env = 'test'
  Rake::Task['curator:setup'].invoke
  SolrWrapper.wrap do |solr|
    solr.with_collection do
      Rake::Task['spec'].invoke
    end
  end
end

task default: :ci
