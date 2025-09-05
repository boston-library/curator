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
  gem 'listen'
end

group :development, :test do
  gem 'azure-storage-blob', '>= 2.0', require: false
  gem 'debug', platforms: %i(mri windows)
  gem 'dotenv-rails', '~> 2.8'
  gem 'factory_bot_rails', '~> 6.5'
  gem 'faker', '~> 3.2'
  gem 'puma', '~> 6.6'
  gem 'rubocop', '~> 1.80.2', require: false
  gem 'rubocop-factory_bot', '~> 2.27.1', require: false
  gem 'rubocop-performance', '~> 1.25.0', require: false
  gem 'rubocop-rails', '~> 2.33.3', require: false
  gem 'rubocop-rspec_rails', '~> 2.31'
end

group :test do
  gem 'climate_control', '~> 1.1'
  gem 'coveralls_reborn', '~> 0.28.0', require: false
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'rspec-rails', '~> 7.1'
  gem 'shoulda-matchers', '~> 6.5'
  gem 'vcr', '~> 6.3'
  gem 'webmock', '~> 3.25'
end
