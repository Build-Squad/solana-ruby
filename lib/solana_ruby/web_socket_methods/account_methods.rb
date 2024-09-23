# frozen_string_literal: true

module SolanaRuby
  module WebSocketMethods
    module AccountMethods
      FINALIZED_OPTIONS = { commitment: 'finalized' }.freeze

      def on_account_change(pubkey, options = FINALIZED_OPTIONS, &block)
        params = [pubkey, options]
        
        subscribe('accountSubscribe', params) do |account_info|
          block.call(account_info)
        end
      end

      def remove_account_change_listener(subscription_id)
        unsubscribe('accountUnsubscribe', subscription_id)
        @subscriptions.delete(subscription_id)
      end
    end
  end
end
