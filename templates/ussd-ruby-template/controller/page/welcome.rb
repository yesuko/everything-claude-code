# frozen_string_literal: true

module Page
  class Welcome < Page::Base
    def process
      # This is the "Canvas" for your UI.
      # Rule: Keep it under 160 characters for USSD compatibility.
      "Welcome to VPOS USSD V2\n\n1. Make Payment\n2. Contact Us\n\n00. Exit"
    end
  end
end
