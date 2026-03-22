# frozen_string_literal: true

module Service
  # The Business Logic Layer Base. Orchestrates API calls and data validation.
  class BaseService
    def initialize(params)
      @params = params
    end

    def self.process(action, params = {})
      new(params).send(action)
    rescue StandardError => e
      LOGGER.error("[Service::#{name}] Action: #{action} — Error: #{e.message}")
      false
    end
  end
end
