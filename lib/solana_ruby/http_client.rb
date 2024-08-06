# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require_relative "http_methods/basic_methods"

module SolanaRuby
  class HttpClient
    include HttpMethods::BasicMethods
    BASE_URL = "https://api.mainnet-beta.solana.com"

    def initialize(endpoint = BASE_URL)
      @uri = URI.parse(endpoint)
    end

    def request(method, params = [])
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(@uri.request_uri, {'Content-Type' => 'application/json'})
      request.body = {
        jsonrpc: "2.0",
        id: 1,
        method: method,
        params: params
      }.to_json

      response = http.request(request)
      JSON.parse(response.body)
    end
  end
end
