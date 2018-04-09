require 'resque/server'
require 'resque/scheduler/server'
require 'active_scheduler'

redis_url = ENV['REDIS_URL'] || 'redis:6379'
Resque.redis = redis_url

yaml_schedule = YAML.load_file('config/resque-schedule.yml')
wrapped_schedule = ActiveScheduler::ResqueWrapper.wrap yaml_schedule
Resque.schedule  = wrapped_schedule
