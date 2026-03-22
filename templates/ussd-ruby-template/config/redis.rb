# frozen_string_literal: true

require 'redis'

# Standard: Initialize Global Redis Client
# You can customize host/port via environment variables
unless defined?($redis)
  $redis = Redis.new(
    host: ENV['REDIS_HOST'] || '127.0.0.1',
    port: ENV['REDIS_PORT'] || 6379,
    db: ENV['REDIS_DB'] || 0
  )

  LOGGER.info("[Redis] Connected to Redis at #{$redis.inspect}")
end
