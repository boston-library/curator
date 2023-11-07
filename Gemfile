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
  gem 'debug', platforms: %i(mri mingw x64_mingw)
  gem 'dotenv-rails', '~> 2.8'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
  gem 'puma', '~> 6.2'
  gem 'rubocop', '~> 1.57.2', require: false
  gem 'rubocop-factory_bot', '~> 2.24.0' ,require: false
  gem 'rubocop-performance', '~> 1.19.1', require: false
  gem 'rubocop-rails', '~> 2.22.1', require: false
  gem 'rubocop-rspec', '~> 2.25.0' , require: false
end

group :test do
  gem 'climate_control', '~> 1.0'
  gem 'coveralls', require: false
  gem 'database_cleaner-active_record', '~> 2'
  gem 'rspec-rails', '~> 6.0'
  gem 'shoulda-matchers', '~> 5.2'
  gem 'vcr', '~> 6.1'
  gem 'webmock', '~> 3.18'
end
