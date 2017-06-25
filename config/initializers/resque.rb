require 'resque/server'
require 'resque/scheduler/server'
redis_url = ENV['REDIS_URL'] || 'redis:6379'
Rails.application.config.active_job.queue_adapter = :resque
Resque.redis = redis_url
Resque::Server.use(Rack::Auth::Basic) do |user, password|  
  password == ENV['RESQUE_ADMIN']
end 
Resque.schedule = YAML.load_file('config/resque-schedule.yml')
