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

  spec.required_ruby_version = '>= 2.5.8'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'aasm', '~> 5.1' # Acts as a state machine. Useful for tracking states of objects and triggering call backs between state trasnistion
  spec.add_dependency 'activerecord-postgres_enum', '~> 1.4' # For using defined postgres enum types
  spec.add_dependency 'acts_as_list', '~> 1.0'
  spec.add_dependency 'addressable', '2.7'
  spec.add_dependency 'after_commit_everywhere', '~> 0.1', '>= 0.1.5' # Required for using aasm with active record
  spec.add_dependency 'attr_json', '~> 1.2'
  spec.add_dependency 'concurrent-ruby-ext', '~> 1.1'
  spec.add_dependency 'connection_pool', '~> 2.2'
  spec.add_dependency 'down', '~> 5.2'
  spec.add_dependency 'htmlentities', '~> 4.3'
  spec.add_dependency 'http', '~> 4.4'
  spec.add_dependency 'oj', '~> 3.10'
  spec.add_dependency 'ox', '~> 2.13'
  spec.add_dependency 'paper_trail', '~> 10.3' # have not implemented this yet but does version control
  spec.add_dependency 'rails', '~> 6.1', '< 6.2'
  spec.add_dependency 'rsolr', '~> 2.3'
  spec.add_dependency 'traject', '~> 3.4'

  spec.add_development_dependency 'image_processing', '~> 1.11'
  spec.add_development_dependency 'mini_magick', '~> 4.10'
  spec.add_development_dependency 'pg', '~> 1.2'
  spec.add_development_dependency 'redis', '~> 4.2'
  spec.add_development_dependency 'solr_wrapper', '>= 2.1', '< 3.0'
end
