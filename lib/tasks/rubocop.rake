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
