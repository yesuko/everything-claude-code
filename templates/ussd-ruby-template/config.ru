# frozen_string_literal: true

require 'sinatra'
require 'redis'
require 'faraday'
require 'phonelib'
require 'json'
require 'logger'

# Standard: Initialize the "World" of the USSD Application
# No Database: Using High-Performance Redis Cache
require './config/logger'
require './config/redis'

# Standard: Initialize all sub-directories
require './util/init'
require './models/init'
require './services/init'
require './controller/init'

# Entry: Run the Sinatra application
run Sinatra::Application
