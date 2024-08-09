# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require 'pry'
require 'base64'
require_relative "http_methods/basic_methods"
require_relative "base_client"

module SolanaRuby
  class HttpClient < BaseClient
    include HttpMethods::BasicMethods
    BASE_URL = "https://api.mainnet-beta.solana.com"

    def initialize(endpoint = BASE_URL)
      @uri = URI.parse(endpoint)
    end

    def request(method, params = [])
      http = Net::HTTP.new(@uri.host, @uri.port)
      # http.use_ssl = true

      request = Net::HTTP::Post.new(@uri.request_uri, {'Content-Type' => 'application/json'})
      request.body = {
        jsonrpc: "2.0",
        id: 1,
        method: method,
        params: params
      }.to_json

      response = http.request(request)
      handle_http_response(response)
    rescue StandardError => e
      handle_error(e)
    end
  end
end

# Testing ....

# client = SolanaRuby::HttpClient.new("http://localhost:8899")

# pubkey = "4aPUVcbh82duG6ChMkMxWS1W21aafQ2f6Sq7PFBcvsZM"

# account_info = client.get_address_lookup_table(pubkey)

# puts "The account is: #{account_info}"
