redis_url = ENV['REDIS_URL'] || 'redis:6379'
Rails.application.config.cache_store = :redis_store, redis_url, { expires_in: 90.minutes }

require 'resque/server'
Rails.application.config.active_job.queue_adapter = :resque
Resque.redis = redis_url
Resque::Server.use(Rack::Auth::Basic) do |user, password|  
  password == ENV['RESQUE_ADMIN']
end 
