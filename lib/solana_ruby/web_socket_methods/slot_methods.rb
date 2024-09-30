# frozen_string_literal: true

module SolanaRuby
  module WebSocketMethods
    # Slot Related Web Socket Methods
    module SlotMethods
      # Subscribe to slot change notifications.
      # Options can include parameters such as commitment level, encoding, etc.
      def on_slot_change(&block)
        # Default to empty params if no options are provided.
        subscribe("slotSubscribe", [], &block)
      end

      # Unsubscribe from slot change notifications.
      def remove_slot_change_listener(subscription_id)
        unsubscribe("slotUnsubscribe", subscription_id)
      end
    end
  end
end
