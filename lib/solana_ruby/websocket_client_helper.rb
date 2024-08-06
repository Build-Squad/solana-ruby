require 'json'
require 'pry'

module SolanaRuby
  class WebsocketClientHelper
    def handle_message(message_data, subscriptions)
      message = JSON.parse(message_data)
      if message['method'] == 'subscription'
        subscription_id = message['params']['subscription']
        if subscriptions[subscription_id]
          subscriptions[subscription_id].call(message['params'])
        else
          puts "No subscription found for ID: #{subscription_id}"
        end
      elsif message['result']
        subscription_id = message['id']
        if subscriptions[subscription_id]
          subscriptions[subscription_id].call(message['result'])
          subscriptions.delete(subscription_id)
        else
          puts "No subscription found for ID: #{subscription_id}"
        end
      end
      subscriptions
    end
  end
end

