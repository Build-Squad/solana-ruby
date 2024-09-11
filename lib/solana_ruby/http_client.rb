# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'pry'
require 'base64'
require 'base58'
require_relative 'base_client'
Dir[File.join(__dir__, 'http_methods', '*.rb')].each { |file| require file }

module SolanaRuby
  class HttpClient < BaseClient
    [HttpMethods::BasicMethods, HttpMethods::LookupTableMethods, HttpMethods::TransactionMethods,
      HttpMethods::SignatureMethods, HttpMethods::BlockhashMethods, HttpMethods::BlockMethods,
      HttpMethods::AccountMethods, HttpMethods::TokenMethods, HttpMethods::SlotMethods].each do |mod|
      include mod
    end
    BASE_URL = 'https://api.mainnet-beta.solana.com'

    def initialize(endpoint = BASE_URL)
      @uri = URI.parse(endpoint)
    end

    def request(method, params = [])
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(@uri.request_uri, {'Content-Type' => 'application/json'})
      request.body = {
        jsonrpc: '2.0',
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
