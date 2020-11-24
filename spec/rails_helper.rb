# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

# have to set here, ENV['SOLR_URL'] not set by Dotenv before Rspec loads Curator::Engine
ENV['SOLR_URL'] = File.read(
  File.expand_path('internal/.env.test', __dir__)
).match(/SOLR_URL=[\w:\/\.]*/).to_s.split('SOLR_URL=').last if ENV['RAILS_ENV'] == 'test'

# NOTE: These are needed for travis since the class_attribute in the remote service requires these to exist
ENV['AUTHORITY_API_URL'] ||= 'http://127.0.0.1:3001'
ENV['ARK_MANAGER_API_URL'] ||= 'http://127.0.0.1:3002'

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
  # NOTE: uncomment this when creating or updating existing specs are wrapped in VCR.use_cassete
  # This will update the yaml files for the specs.
  # c.default_cassette_options = { record: :new_episodes }
  c.cassette_library_dir = 'spec/vcr'
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.ignore_request do |request|
    request.uri =~ /solr/
  end
end

require 'rspec/rails'
require 'database_cleaner/active_record'
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
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.cleaning do
      FactoryBot.lint
    end
    VCR.use_cassette('load_seeds') do
      Curator::Engine.load_seed
    end
    WebMock.reset!
  end

  config.before(:each) do |spec|
    unless spec.metadata[:type] == :service
      DatabaseCleaner.start if !spec.metadata[:location].match?('descriptive_field_sets')
    end
  end

  config.append_after(:each) do |spec|
    unless spec.metadata[:type] == :service
      DatabaseCleaner.clean if !spec.metadata[:location].match?('descriptive_field_sets')
    end
  end

  config.after(:suite) do
    # Just in case sequences persist between tests reset them
    FactoryBot.rewind_sequences
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

  config.define_derived_metadata(file_path: Regexp.new('/spec/lib/curator/serializers')) do |metadata|
    metadata[:type] = :lib_serializers
  end

  config.define_derived_metadata(file_path: Regexp.new('/spec/serializers/')) do |metadata|
    metadata[:type] = :serializers
  end

  config.define_derived_metadata(file_path: Regexp.new('/spec/decorators/')) do |metadata|
    metadata[:type] = :decorators
  end
  # TODO: Create derived metadata for serializers once we switch to blueprinter

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
