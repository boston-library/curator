namespace :commonwealth_curator do
  desc "Load and run seed task"
  task :run_seed do
    CommonwealthCurator::Engine.load_seed
  end
end
