# frozen_string_literal: true
namespace :curator do
  desc "Setup and install database migrations/ run seeds"
  task setup: :environment do
    Rake::Task['db:create'].invoke
    if Rake::Task.task_defined?("active_storage:install")
      Rake::Task['active_storage:install'].invoke
    else
      fail "Active Storage is Not Installed!"
    end
    Rake::Task['db:migrate'].invoke
    # Curator::Engine.load_seed
  end


  desc "Load and run seed task"
  task load_seed: :environment do
    Curator::Engine.load_seed
  end
end
