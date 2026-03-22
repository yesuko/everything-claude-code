# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'active_support/all'

# Standard: Start with the Global Logger and Redis (V2 Standard)
require './config/logger'
require './config/redis'

# Standard: Initialize all sub-directories
Dir['./util/*.rb'].each { |file| require file }
Dir['./models/*.rb'].each { |file| require file }
Dir['./services/*.rb'].each { |file| require file }
Dir['./controller/**/*.rb'].each { |file| require file }

# Main USSD Entry Point
# The Telco Gateway MUST send a POST with JSON body (msisdn, msg_type, ussd_body, session_id)
post '/' do
  content_type :json
  # Standard: Every request is funneled through Dial::Manager
  Dial::Manager.new(request.body.read).process
end
