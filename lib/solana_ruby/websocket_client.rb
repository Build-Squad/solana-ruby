# frozen_string_literal: true

require 'websocket-client-simple'
require 'securerandom'
require 'json'
require 'pry'

module SolanaRuby
  class WebsocketClient
    def initialize(url)
      @url = url
      @@subscriptions = {}
      @ws = WebSocket::Client::Simple.connect(@url)

      setup_handlers
    end

    def subscribe(method, params = nil, &block)
      id = generate_id
      @@subscriptions[id] = block
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
        data = JSON.parse(msg.data)
        if data['id'] && @@subscriptions[data['id']]
          @@subscriptions[data['id']].call(data['result'])
        elsif data['method'] && data['params']
          @@subscriptions.each do |id, block|
            block.call(data['params']) if block
          end
        else
          puts "Unhandled message: #{msg.data}"
        end
      end

      @ws.on :open do
        puts 'Websocket connection established.'
      end

      @ws.on :close do |e|
        puts "Websocket connection closed: #{e.inspect}"
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

# account_pubkey = "9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g"

# # Subscribe to account updates
# subscription_id = client.subscribe("slotSubscribe") do |message|
#   puts "The updates is: #{message}"
# end

# # Simulate running for a while to receive messages
# sleep(120)

# # Unsubscribe
# client.unsubscribe("slotSubscribe", subscription_id)


