# frozen_string_literal: true

module Dial
  class Manager
    def initialize(json)
      @params = JSON.parse(json)&.with_indifferent_access
      @message_type = @params[:msg_type]
      @mobile_number = @params[:msisdn]
      @ussd_body = @params[:ussd_body]&.delete_prefix('*')&.delete_suffix('#')
      @session_id = @params[:session_id]
      @segments = @ussd_body&.split('*') || []
    end

    def process
      LOGGER.info("[Dial::Manager] MSISDN: #{@mobile_number} — Type: #{@message_type} — Body: #{@ussd_body}")

      case @message_type
      when '0' # START: Initial Dial
        handle_ussd_flow
      when '1' # CONTINUE: Menu Response
        handle_continuous_dial
      when '2' # RELEASE: Session End
        handle_release
      else
        handle_unknown
      end
    rescue StandardError => e
      LOGGER.error("[Dial::Manager] Error: #{e.message}\n#{e.backtrace[0..3].join("\n")}")
      "USS_FAIL: Internal system error"
    end

    private

    def handle_ussd_flow
      # Step 1: Redis "Continue Session" Check (Agropay Style)
      cached_session = Cache.fetch(@params) # Fetches from Redis via session_id-msisdn

      if cached_session
        LOGGER.info("[Dial::Manager] Resuming Session from Redis Cache")
        Menu::Manager.process(@params, cached_data: cached_session.cache)
      elsif @segments.length > 1
        handle_long_string_flow
      else
        handle_first_dial
      end
    end

    def handle_long_string_flow
      inputs = @segments.slice(1..-1)
      # Store metadata in Redis for next steps
      Cache.store(@params.merge(cache: { start_time: Time.now }.to_json))
      Menu::Manager.process(@params, reset: true, sequence: inputs)
    end

    def handle_first_dial
      # Store initial session metadata in Redis (Agropay standard)
      Cache.store(@params.merge(cache: { last_page: 'Page::Welcome' }.to_json))
      Menu::Manager.process(@params, reset: true)
    end

    def handle_continuous_dial
      Menu::Manager.process(@params)
    end

    def handle_release
      # Cleanup Redis session (Optional, Redis has TTL)
      $redis.del("#{@session_id}-#{@mobile_number}-cache")
      ""
    end

    def handle_unknown
      "USS_FAIL: Unknown message type"
    end
  end
end
