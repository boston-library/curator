# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in commonwealth_curator.gemspec.
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
  gem 'awesome_print', '~> 1.8'
  gem 'dotenv-rails', '~> 2.7'
  gem 'factory_bot_rails', '~> 5.0'
  gem 'faker', '~> 2.6.0'
  gem 'pry', '~> 0.12'
  gem 'pry-byebug', '~> 3.8'
  gem 'pry-rails', '~> 0.3.9'
  gem 'puma', '~> 4.3'
  gem 'rubocop', '~> 0.75.1', require: false
  gem 'rubocop-performance', '~> 1.5', require: false
  gem 'rubocop-rails', '~> 2.4.2', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'climate_control', '~> 0.1'
  gem 'coveralls', require: false
  gem 'database_cleaner', '~> 1.8'
  gem 'rspec-rails', '~> 3.9', '< 4.0'
  gem 'shoulda-matchers', '~> 4.1'
  gem 'vcr', '~> 5.1.0'
  gem 'webmock', '~> 3.8'
end
