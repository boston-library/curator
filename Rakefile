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
  task.requires << 'rubocop-factory_bot'
  task.fail_on_error = true
  # WARNING: Make sure the bottom 3 lines are always commented out before committing
  # task.options << '--safe-auto-correct'
  # task.options << '--disable-uncorrectable'
  # task.options << '-d'
end

Dir.glob('lib/tasks/*.rake').each { |r| import r }

require 'solr_wrapper/rake_task'

desc 'Check that zeitwerk can eager load the application'
task :check_zeitwerk do
  if Rake::Task.task_defined?('app:zeitwerk:check')
    puts 'Invoking app:zeitwerk:check to check eager loading...'
    Rake::Task['app:zeitwerk:check'].invoke
    puts 'Zeitwerk eager load check success!'
  else
    puts 'app:zeitewerk:check is not defined. skipping check...'
  end
end

desc 'Lint, set up test app, spin up Solr, and run specs'
task ci: [:rubocop, :check_zeitwerk] do
  puts 'running continuous integration'
  SolrWrapper.wrap do |solr|
    solr.with_collection do
      Rake::Task['spec'].invoke
    end
  end
end

task default: :ci
