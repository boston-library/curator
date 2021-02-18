# frozen_string_literal: true

require 'rails/generators'

module Curator
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc 'InstallGenerator Curator'

    def add_initializer
      template 'config/initializers/curator.rb'
    end
  end
end
