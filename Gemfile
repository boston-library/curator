# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in curator.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :development, :test do
  gem 'awesome_print', '~> 1.9'
  gem 'azure-storage-blob', '>= 2.0', require: false
  gem 'dotenv-rails', '~> 2.8'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 2.22'
  gem 'pry', '~> 0.13.1'
  gem 'pry-rails'
  gem 'puma', '~> 6.2'
  gem 'rubocop', '~> 0.80.1', require: false
  gem 'rubocop-performance', '~> 1.6', require: false
  gem 'rubocop-rails', '~> 2.5', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'climate_control', '~> 1.0'
  gem 'coveralls', require: false
  gem 'database_cleaner-active_record', '~> 2'
  gem 'rspec-rails', '~> 5.1'
  gem 'shoulda-matchers', '~> 5.2'
  gem 'vcr', '~> 6.1'
  gem 'webmock', '~> 3.18'
end
