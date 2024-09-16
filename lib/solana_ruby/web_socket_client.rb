# frozen_string_literal: true

require 'websocket-client-simple'
require 'securerandom'
require 'json'
require 'pry'
require_relative 'web_socket_handlers'

module SolanaRuby
  class WebSocketClient
    include WebSocketHandlers
    attr_reader :subscriptions

    def initialize(url, auto_reconnect: true, reconnect_delay: 5)
      @url = url
      @subscriptions = {}
      @auto_reconnect = auto_reconnect
      @reconnect_delay = reconnect_delay
      connect
    end

    def connect
      @ws = WebSocket::Client::Simple.connect(@url)
      setup_handlers(@ws, self)
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

    def handle_message(data)
      if data['id'] && @subscriptions[data['id']]
        @subscriptions[data['id']].call(data['result'])
      elsif data['method'] && data['params']
        @subscriptions.each do |id, block|
          block.call(data['params']) if block
        end
      else
        puts "Unhandled message: #{data}"
      end
    end

    def attempt_reconnect
      puts "Attempting to reconnect in #{@reconnect_delay} seconds..."
      sleep @reconnect_delay
      connect
    end

    private

    def generate_id
      SecureRandom.uuid
    end
  end
end

# testing

# client = SolanaRuby::WebSocketClient.new("wss://api.devnet.solana.com")

# account_pubkey = "9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g"
# params = [
#     {
#       mentionsAccountOrProgram: "11111111111111111111111111111111"
#     },
#     {
#       commitment: "confirmed",
#       encoding: "base64",
#       showRewards: true,
#       transactionDetails: "full"
#     }
#   ]

# # Subscribe to account updates
# subscription_id = client.subscribe("blockSubscribe", ['all']) do |message|
#   puts "The updates is: #{message}"
# end

# # Simulate running for a while to receive messages
# sleep(10)

# # Unsubscribe
# res = client.unsubscribe("blockUnsubscribe", subscription_id)

# puts "unsubscribe: #{res}, #{subscription_id}"
