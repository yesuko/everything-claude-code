# frozen_string_literal: true

module Page
  class Payment < Page::Base
    def process
      # Asking for user input
      "Make Payment\n\nEnter Amount (GHS):\n\n0. Back"
    end
  end
end
