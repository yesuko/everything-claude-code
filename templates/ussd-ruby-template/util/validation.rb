# frozen_string_literal: true

module Util
  class Validation
    class << self
      # Standard: Ghana phone validation (233XXXXXXXXX)
      def valid_msisdn?(msisdn)
        msisdn&.match?(/\A233[25][0-9]{8}\z/)
      end

      # Normalize MSISDN: 0244 -> 233244
      def normalize_msisdn(msisdn)
        return msisdn if msisdn&.start_with?('233')
        "233#{msisdn[1..]}" if msisdn&.start_with?('0')
      end

      # Simple Name Validation
      def valid_name?(name)
        return false if name.nil? || name.empty?
        name.length > 2 && name.match?(/\A[a-zA-Z\s]+\z/)
      end

      # Amount Validation (Numerical)
      def valid_amount?(amount)
        amount&.match?(/\A\d+(\.\d{1,2})?\z/)
      end
    end
  end
end
