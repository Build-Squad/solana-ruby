# frozen_string_literal: true

require_relative "solana_ruby/version"
require_relative "solana_ruby/http_client"
require_relative "solana_ruby/websocket_client"
# Dir["solana_ruby/*.rb"].each { |f| require_relative f.delete(".rb") }

module SolanaRuby
  # class Error < StandardError; end
  class Client < SolanaRuby::HttpClient
  end
end
