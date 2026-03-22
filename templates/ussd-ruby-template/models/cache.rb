# frozen_string_literal: true

class Cache
  attr_accessor :mobile_number, :session_id, :cache

  def initialize(params)
    @session_id = params[:session_id]
    @mobile_number = params[:mobile_number]
    @cache = params[:cache] || '{}'
  end

  def self.store(params)
    session_id = params[:session_id]
    mobile_number = params[:msisdn]
    cache = { cache: params[:cache] }

    key = "#{session_id}-#{mobile_number}-cache"
    $redis.hset(key, cache)

    # Standard: Set TTL for session (5 minutes = 300 seconds)
    $redis.expire(key, 300)
    LOGGER.info("[Cache] Stored data for session: #{session_id}")
  end

  def self.fetch(params)
    session_id = params[:session_id]
    mobile_number = params[:msisdn]

    key = "#{session_id}-#{mobile_number}-cache"
    tracking_data = $redis.hgetall(key)

    # Standard: Handle empty hash from HGETALL
    if tracking_data.empty?
      nil
    else
      new(tracking_data.with_indifferent_access)
    end
  end
end
