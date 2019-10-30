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

APP_RAKEFILE = File.expand_path("spec/internal/Rakefile", __dir__)
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'


require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)


require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rails'
  task.requires << 'rubocop-rspec'
  # task.options << '--safe-auto-correct'
  # task.options << '--disable-uncorrectable'
  # task.options << '-d'
end
#rubocop --auto-gen-config --require rubocop-rails rubocop-rspec
task default: [:spec, :rubocop]
