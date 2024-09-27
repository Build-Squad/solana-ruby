# frozen_string_literal: true

module SolanaRuby
  module WebSocketMethods
    # Root Related Web Socket Methods
    module RootMethods
      def on_root_change(&block)
        subscribe("rootSubscribe", [], &block)
      end

      def remove_root_listener(subscription_id)
        unsubscribe("rootUnsubscribe", subscription_id)
      end
    end
  end
end
