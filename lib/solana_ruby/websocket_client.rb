require 'websocket-client-simple'
require 'securerandom'
require 'json'
require 'pry'
require_relative 'websocket_client_helper'

module SolanaRuby
  class WebsocketClient
    def initialize(url)
      @url = url
      @subscriptions = {}
      @ws = WebSocket::Client::Simple.connect(@url)

      setup_handlers
    end

    def subscribe(method, params = nil, &block)
      id = generate_id
      @subscriptions[id] = block
      message = {
        jsonrpc: '2.0',
        id: id,
        method: method
      }
      message[:params] = params if params
      sleep 2
      @ws.send(message.to_json)
      id
    end

    def unsubscribe(method, subscription_id)
      message = {
        jsonrpc: '2.0',
        id: generate_id,
        method: method,
        params: [subscription_id]
      }
      @ws.send(message.to_json)
    end

    private

    def setup_handlers
      @ws.on :message do |msg|
        ws_client_helper = SolanaRuby::WebsocketClientHelper.new
        ws_client_helper.handle_message(msg.data)
      end

      @ws.on :open do
        puts 'Connected'
      end

      @ws.on :close do |e|
        puts "Connection closed: #{e.inspect}"
      end

      @ws.on :error do |e|
        puts "Error: #{e.inspect}"
      end
    end

    def generate_id
      SecureRandom.uuid
    end
  end
end


# client = SolanaRuby::WebsocketClient.new("wss://api.devnet.solana.com")

# account_pubkey = ""

# # Subscribe to account updates
# subscription_id = client.subscribe("rootSubscribe") do |message|
#   puts "Received slot update: #{message}"
# end

# # Simulate running for a while to receive messages
# sleep(60)

# # Unsubscribe
# client.unsubscribe("rootUnsubscribe", subscription_id)


