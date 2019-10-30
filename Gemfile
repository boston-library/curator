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
group :development, :test do
  gem 'awesome_print', '~> 1.8.0'
  gem 'dotenv-rails', '~> 2.7'
  gem 'factory_bot_rails', '~> 5.0'
  gem 'faker', '~> 2.6.0'
  gem 'pry', '~> 0.12.2'
  gem 'pry-byebug', '~> 3.7.0'
  gem 'pry-rails', '~> 0.3.9'
  gem 'rubocop', '~> 0.75.0', require: false
  gem 'rubocop-rails', '~> 2.3.2', require: false
  gem 'rubocop-rspec', require: false
  gem 'solr_wrapper', '~> 2.1.0'
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner',  '~> 1.7'
  gem 'rspec-activemodel-mocks', '~> 1.1.0'
  gem 'rspec-rails', '~> 3.8.0'
  gem 'shoulda-matchers', '~> 4.1'
  gem 'vcr', '~> 5.0.0'
  gem 'webmock', '~> 3.7.6'
end
