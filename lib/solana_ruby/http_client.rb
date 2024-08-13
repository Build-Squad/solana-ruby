# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require 'pry'
require 'base64'
require 'base58'
require_relative "http_methods/basic_methods"
require_relative "http_methods/lookup_table_methods"
require_relative "http_methods/transaction_methods"
require_relative "http_methods/signature_methods"
require_relative "http_methods/blockhash_methods"
require_relative "http_methods/block_methods"
require_relative "base_client"

module SolanaRuby
  class HttpClient < BaseClient
    include HttpMethods::BasicMethods
    include HttpMethods::LookupTableMethods
    include HttpMethods::TransactionMethods
    include HttpMethods::SignatureMethods
    include HttpMethods::BlockhashMethods
    include HttpMethods::BlockMethods
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

# pubkey = "9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g"

# signatures = "267iujSpqG933rm4UkkF8gv4W8cASfawqRGaudMXtoX8WcSzSNXtfTk2dNjrsTnhQsYU8Q1F1fceDQmLeDEFKySs"

# options = { "limit"=> 2 }

# current_slot = client.get_slot()
# account_info = client.get_block_signatures(current_slot)
# puts "The signature status is: #{account_info}"
