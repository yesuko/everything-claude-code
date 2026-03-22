# frozen_string_literal: true

root = ::File.dirname(__FILE__)

# Load core state machine
require ::File.join(root, 'dial/manager')
require ::File.join(root, 'menu/manager')

# Load the UI Pages
require ::File.join(root, 'page/base')
require ::File.join(root, 'page/welcome')
require ::File.join(root, 'page/payment')
require ::File.join(root, 'page/contact_us')

# Load the Services
require ::File.join(root, 'service/base_service')
# Example specialized services:
# require ::File.join(root, 'service/payment_service')
# require ::File.join(root, 'service/entity_service')
