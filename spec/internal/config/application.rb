require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

Dotenv::Railtie.load

require "curator"

module Internal
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    # config.active_support.cache_format_version = 7.0
    # config.active_support.disable_to_s_conversion = true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.api_only = true
    if Rails.env.development?
      console do
        require 'awesome_print'
        AwesomePrint.irb!
        config.console = IRB
      end
    end
    config.active_storage.analyzers = []
    config.active_storage.previewers = []
  end
end
