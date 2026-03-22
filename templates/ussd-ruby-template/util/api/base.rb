# frozen_string_literal: true

require 'faraday'

module Util
  module Api
    # The External Connection Layer. All REST API calls flow through here.
    class Base
      def initialize(url, options = {})
        @url = url
        @options = options
        @conn = Faraday.new(url: @url) do |f|
          f.request :url_encoded
          f.adapter Faraday.default_adapter
          f.options.timeout = 10 # 10s USSD limit
        end
      end

      # Generic Post helper
      def post(path, body, headers = {})
        response = @conn.post(path) do |req|
          req.headers = headers if headers.any?
          req.body = body.to_json
        end
        # Return standardized response
        Util::Api::Response.new(response)
      rescue StandardError => e
        LOGGER.error("[Api::Post] URL: #{@url} — Error: #{e.message}")
        nil
      end
    end

    class Response
      attr_reader :status, :body

      def initialize(resp)
        @status = resp.status
        @body = JSON.parse(resp.body)&.with_indifferent_access rescue {}
      end

      def success?
        @status >= 200 && @status < 300
      end
    end
  end
end
