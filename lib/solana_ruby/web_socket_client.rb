# frozen_string_literal: true

require 'websocket-client-simple'
require 'securerandom'
require 'json'
require 'pry'
require_relative 'web_socket_handlers'
Dir[File.join(__dir__, 'web_socket_methods', '*.rb')].each { |file| require file }

module SolanaRuby
  class WebSocketClient
    include WebSocketHandlers
    include WebSocketMethods::AccountMethods
    include WebSocketMethods::LogMethods
    include WebSocketMethods::SignatureMethods
    attr_reader :subscriptions

    def initialize(url, auto_reconnect: true, reconnect_delay: 5)
      @url = url
      @subscriptions = {}
      @auto_reconnect = auto_reconnect
      @reconnect_delay = reconnect_delay
      @connected = false
      @ws = nil
      connect
    end

    def connect
      return if @connected

      # Close existing WebSocket if it exists
      @ws&.close if @ws

      @ws = WebSocket::Client::Simple.connect(@url)
      setup_handlers(@ws, self)
      @connected = true
    rescue StandardError => e
      puts "Failed to connect: #{e.message}"
      attempt_reconnect
    end

    def reconnect
      @connected = false
      connect
    end

    def subscribe(method, params = nil, &block)
      id = SecureRandom.uuid
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
        id: SecureRandom.uuid,
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
      return unless @auto_reconnect

      puts "Attempting to reconnect in #{@reconnect_delay} seconds..."
      @connected = false
      sleep @reconnect_delay
      reconnect
    end
  end
end
