redis_url = ENV['REDIS_URL'] || 'redis:6379'
Rails.application.config.cache_store = :redis_store, redis_url, { expires_in: 90.minutes }
