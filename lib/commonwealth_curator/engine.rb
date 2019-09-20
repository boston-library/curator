# frozen_string_literal: true
module CommonwealthCurator
  class Engine < ::Rails::Engine
    isolate_namespace CommonwealthCurator
    engine_name 'commonwealth_curator'

    config.generators do |g|
      g.api_only = true
      g.test_framework :rspec, :fixture => false
    end
    
  end
end
