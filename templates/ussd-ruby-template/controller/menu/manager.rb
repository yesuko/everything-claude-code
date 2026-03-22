# frozen_string_literal: true

module Menu
  # The Switchboard Layer. Orchestrates transition between UI Pages.
  class Manager
    class << self
      def process(params, reset: false, sequence: [])
        @params = params
        @input = params[:ussd_body] # User selection from the phone keypad
        @sequence = sequence # Pre-populated inputs (Long String Flow)

        # Reset flag = 'START' message (Initial dial)
        if reset
          # Start by processing the welcome page
          if @sequence.any?
            # State 1a: Long String Flow — "Replaying" inputs
            handle_sequence(reset: true)
          else
            # State 1b: Normal Entry — Initial Welcome
            Page::Welcome.process(@params)
          end
        else
          # State 2: Progressing through the menu via normal keypad entry
          route_logic
        end
      end

      private

      def handle_sequence(reset: false)
        # Replays the dial string inputs. Example: ["1", "50"]
        # In a real app, this would involve state persistence.
        # This example just demonstrates the principle.

        # Pull first input from sequence
        @input = @sequence.shift

        # If we have more in the sequence, recursively process until we reach the target page
        # In actual USSD, this involves state transitions in the DB session.
        route_logic if @input
      end

      def route_logic(input = @input)
        # Branching Logic
        case input
        when '1' # Selection from Welcome (Make Payment)
          # If we have a sequence (like *713*1*50#), the '50' is next in the array.
          # Here we would handle the payment logic for the $50 amount.
          Page::Payment.process(@params)
        when '2' # Selection from Welcome (Contact Us)
          Page::ContactUs.process(@params)
        when '0' # Return Back to Root
          Page::Welcome.process(@params)
        when '00' # Exit
          "Thank you for using VPOS. Goodbye!"
        else
          # Error State / Unknown selection
          "Invalid selection.\n\n0. Back"
        end
      end
    end
  end
end
