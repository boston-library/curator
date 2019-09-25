# frozen_string_literal: true
namespace :commonwealth_curator do
  desc "Setup and install database migrations/ run seeds"
  task setup: :environment do
    Rake::Task['db:create'].invoke
    if Rake::Task.task_defined?("active_storage:install")
      Rake::Task['active_storage:install'].invoke
    else
      fail "Active Storage is Not Installed!"
    end
    Rake::Task['db:migrate'].invoke
    # CommonwealthCurator::Engine.load_seed
  end


  desc "Load and run seed task"
  task load_seed: :environment do
    CommonwealthCurator::Engine.load_seed
  end
end
