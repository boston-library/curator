# frozen_string_literal: true
$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require 'curator/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'curator'
  spec.version     = Curator::VERSION
  spec.authors     = ['bbarberBPL']
  spec.email       = ['bbarber@bpl.org']
  spec.homepage    = 'https://github.com/boston-library/curator'
  spec.summary     = 'Summary of Curator.'
  spec.description = 'Description of Curator.'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 2.5.5'

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
  spec.add_dependency 'oj', '~> 3.9.1'
  spec.add_dependency 'ox', '~> 2.11'
  spec.add_dependency 'paper_trail', '~> 10.3'
  spec.add_dependency 'acts_as_list', '~> 0.9'

  spec.add_development_dependency 'redis', '~> 4.1'
  spec.add_development_dependency 'net-http-persistent', '~> 3.1'
  spec.add_development_dependency 'pg', '~> 1.1'
  spec.add_development_dependency 'faraday', '~> 0.15'
  spec.add_development_dependency 'faraday_middleware', '~> 0.13'
  spec.add_development_dependency 'addressable', '2.7'
  spec.add_development_dependency 'rspec-rails', '~> 3.8.0'
  spec.add_development_dependency 'factory_bot_rails', '~> 5.0'
  spec.add_development_dependency 'dotenv-rails', '~> 2.7'
end
