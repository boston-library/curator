# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

# have to set here, ENV['SOLR_URL'] not set by Dotenv before Rspec loads Curator::Engine
ENV['SOLR_URL'] = File.read(
  File.expand_path('internal/.env.test', __dir__)
).match(/SOLR_URL=[\w:\/\.]*/).to_s.split('SOLR_URL=').last if ENV['RAILS_ENV'] == 'test'

require File.expand_path('./internal/config/environment', __dir__)

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'simplecov'
require 'coveralls'
Coveralls.wear!('rails')

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter '/spec/'
end

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.ignore_request do |request|
    request.uri =~ /solr/
  end
end

require 'rspec/rails'
require 'database_cleaner'
require 'factory_bot_rails'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Curator::Engine.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.cleaning do
      FactoryBot.lint
    end
    VCR.use_cassette('load_seeds') do
      Curator::Engine.load_seed
    end
    WebMock.reset!
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |spec|
    DatabaseCleaner.cleaning do
      spec.run
    end
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  config.define_derived_metadata(file_path: Regexp.new('/spec/services/')) do |metadata|
    metadata[:type] = :service
  end

  config.define_derived_metadata(file_path: Regexp.new('/spec/lib/')) do |metadata|
    metadata[:type] = :lib
  end

  # TODO: Create derived metadata for serializers once we switch to blueprinter

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
