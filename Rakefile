# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'resque/tasks'
require 'resque/scheduler/tasks'

Rails.application.load_tasks

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ['--display-cop-names']
  end

  desc 'Runs the PR suite'
  task pr: %i[spec rubocop:auto_correct]
rescue LoadError => e
  raise e unless ENV['RAILS_ENV'] == 'production'
end
