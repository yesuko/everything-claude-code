# frozen_string_literal: true

module Util
  class Constant
    # Standard: Centralized string management (DRY)
    APP_NAME = "VPOS USSD GATEWAY"
    SUPPORT_CONTACT = "+233 24 000 0000"
    CURRENCY = "GHS"

    # State Keys
    MSG_TYPE_START = '0'
    MSG_TYPE_CONTINUE = '1'
    MSG_TYPE_RELEASE = '2'

    # Error Messages
    ERR_GENERIC = "USS_FAIL: System unavailable. Please try later."
    ERR_INVALID_INPUT = "USS_FAIL: Invalid selection."
  end
end
