# frozen_string_literal: true

module SolanaRuby
  module WebSocketHandlers
    def setup_handlers(ws, client)
      ws.on :message do |msg|
        begin
          data = JSON.parse(msg.data)
          if data['error']
            puts "Error: #{data['error']['message']} with the code #{data['error']['code']}"
          else
            client.handle_message(data)
          end
        rescue JSON::ParserError => e
          puts "Failed to parse message: #{e.message}"
        end
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
