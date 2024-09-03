# frozen_string_literal: true

module SolanaRuby
  class BaseClient
    require 'active_support/core_ext/string/inflections'
    
    private

    def handle_http_response(response)
      body = JSON.parse(response.body)
      # puts "body:==== #{body}"
      if response.is_a?(Net::HTTPSuccess)
        if body['error']
          raise "API Error: #{body['error']['code']} - #{body['error']['message']}"
        else
          return body
        end
      else
        raise "HTTP Error: #{response.code} - #{body['error']['message']}"
      end
    rescue JSON::ParserError
      raise "Invalid JSON response: #{response.body}"
    end

    def handle_error(error)
      case error
      when Timeout::Error
        raise SolanaError.new('Request timed out')
      when SocketError
        raise SolanaError.new('Failed to connect to the server')
      else
        raise SolanaError.new("An unexpected error occurred: #{error.message}")
      end
    end
  end

  class SolanaError < StandardError
    def initialize(message)
      super(message)
    end

    def backtrace
      []
    end
  end
end
