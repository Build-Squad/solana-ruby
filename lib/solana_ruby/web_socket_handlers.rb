# frozen_string_literal: true

module SolanaRuby
  module WebSocketHandlers
    def self.setup_handlers(ws, client)
      ws.on :message do |msg|
        data = JSON.parse(msg.data)
        client.handle_message(data)
      end

      ws.on :open do
        puts 'Web Socket connection established.'
      end

      ws.on :close do |e|
        puts "Web Socket connection closed: #{e.inspect}"
      end

      ws.on :error do |e|
        puts "Error: #{e.inspect}"
      end
    end
  end
end
