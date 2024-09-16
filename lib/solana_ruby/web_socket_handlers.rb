# frozen_string_literal: true

module SolanaRuby
  module WebSocketHandlers
    def setup_handlers(ws, client)
      ws.on :message do |msg|
        data = JSON.parse(msg.data)
        client.handle_message(data)
      end

      ws.on :open do
        puts 'Web Socket connection established.'
      end

      ws.on :close do |e|
        puts "Web Socket connection closed: #{e.inspect}"
        client.attempt_reconnect if client.instance_variable_get(:@auto_reconnect)
      end

      ws.on :error do |e|
        puts "Error: #{e.inspect}"
        client.attempt_reconnect if client.instance_variable_get(:@auto_reconnect)
      end
    end
  end
end
