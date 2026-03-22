# frozen_string_literal: true

module Page
  # The UI Layer Base. Inherit from this to build USSD screens.
  class Base
    def initialize(params)
      @params = params
      @mobile_number = params[:msisdn]
      @ussd_body = params[:ussd_body]
      @session_id = params[:session_id]
      @page_id = params[:page_id] # State tracking
    end

    def self.process(params)
      new(params).process
    end

    # Abstract method to be implemented by sub-pages
    def process
      raise NotImplementedError, "#{self.class} has not implemented method 'process'"
    end
  end
end
