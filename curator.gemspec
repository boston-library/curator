# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

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

  spec.required_ruby_version = '>= 3.1', '< 3.2'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'aasm', '~> 5.5' # Acts as a state machine. Useful for tracking states of objects and triggering call backs between state trasnistion
  spec.add_dependency 'activerecord-postgres_enum', '~> 1.7', '< 2.0' # For using defined postgres enum types
  spec.add_dependency 'acts_as_list', '~> 1.1'
  spec.add_dependency 'addressable', '>= 2.8.1'
  spec.add_dependency 'after_commit_everywhere', '~> 1.3' # Required for using aasm with active record
  spec.add_dependency 'alba', '~> 2.2'
  spec.add_dependency 'attr_json', '~> 2.3'
  spec.add_dependency 'concurrent-ruby-ext', '~> 1.2'
  spec.add_dependency 'connection_pool', '~> 2.4'
  spec.add_dependency 'down', '~> 5.4'
  spec.add_dependency 'htmlentities', '~> 4.3' # TODO: Look into replacing this since the last released in 2014. I recommend turning this into its own parser class.
  spec.add_dependency 'http', '~> 5.2'
  spec.add_dependency 'mime-types', '~> 3.4'
  spec.add_dependency 'nokogiri', '>= 1.16.2'
  spec.add_dependency 'oj', '~> 3.16'
  spec.add_dependency 'ox', ' ~> 2.14'
  spec.add_dependency 'paper_trail', '~> 12.3'
  spec.add_dependency 'paper_trail-association_tracking', '~> 2.2'
  spec.add_dependency 'rails', '~> 6.1.7', '< 7'
  spec.add_dependency 'rsolr', '~> 2.6'
  spec.add_dependency 'traject', '~> 3.8'

  spec.add_development_dependency 'image_processing', '~> 1.12'
  spec.add_development_dependency 'mini_magick', '~> 4.12'
  spec.add_development_dependency 'pg', '>= 0.18', '< 2.0'
  spec.add_development_dependency 'redis', '~> 4.8', '< 5'
  spec.add_development_dependency 'solr_wrapper', '~> 4'
end
