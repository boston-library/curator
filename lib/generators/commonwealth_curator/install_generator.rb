# frozen_string_literal: true
require 'rails/generators'
class CommonwealthCurator::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def install
    run_bundle_install
    install_active_storage
    install_paper_trail
    setup_database
  end

  private
  def run_bundle_install
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def install_active_storage
    rake 'active_storage:install'
  end

  def install_paper_trail
    generate 'paper_trail:install'
  end

  def setup_database
    rake 'db:create'
    rake 'db:migrate'
    rake 'commonwealth_curator:load_seed'
  end
end
