# frozen_string_literal: true
namespace :curator do
  desc "Setup and install database migrations/ run seeds"
  task setup: :environment do
    puts "Staring Task!"
    puts "............"
    puts "Invoking db:create..."
    Rake::Task['db:create'].invoke
    if Rake::Task.task_defined?("active_storage:install")
      puts "Invoking active_storage:install..."
      Rake::Task['active_storage:install'].invoke
    else
      fail "Active Storage is Not Installed!"
    end
    puts "Invoking db:migrate..."
    Rake::Task['db:migrate'].invoke
    puts "Invoking curator:load_seed..."
    Rake::Task['curator:load_seed'].invoke
    puts "Finished Task!"
  end


  desc "Load and run seed task"
  task load_seed: :environment do
    Curator::Engine.load_seed
  end
end
