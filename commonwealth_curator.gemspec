# frozen_string_literal: true
$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "commonwealth_curator/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "commonwealth_curator"
  spec.version     = CommonwealthCurator::VERSION
  spec.authors     = ["bbarberBPL"]
  spec.email       = ["bbarber@bpl.org"]
  spec.homepage    = "https://github.com/boston-library/commonwealth_curator"
  spec.summary     = "Summary of CommonwealthCurator."
  spec.description = "Description of CommonwealthCurator."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'rails', '~> 5.2.3'
  spec.add_dependency 'active_model_serializers', '~> 0.10.0'
  spec.add_dependency 'attr_json', '~> 0.7.0'
  spec.add_dependency 'oj'

  spec.add_development_dependency 'redis'
  spec.add_development_dependency 'faraday'
  spec.add_development_dependency 'faraday_middleware'
  spec.add_development_dependency 'addressable'
  spec.add_development_dependency 'net-http-persistent'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'rspec-rails', '~> 3.8.0'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'dotenv-rails'
end
