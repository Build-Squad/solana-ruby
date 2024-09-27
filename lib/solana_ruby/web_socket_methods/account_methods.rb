# frozen_string_literal: true

module SolanaRuby
  module WebSocketMethods
    # Acccount Related Web Socket Methods
    module AccountMethods
      FINALIZED_OPTIONS = { commitment: "finalized" }.freeze
      ENCODING_OPTIONS = { encoding: "base64" }.freeze

      def on_account_change(pubkey, options = FINALIZED_OPTIONS, &block)
        params = [pubkey, options]

        subscribe("accountSubscribe", params) do |account_info|
          block.call(account_info)
        end
      end

      # Unsubscribe from account change updates
      def remove_account_change_listener(subscription_id)
        unsubscribe("accountUnsubscribe", subscription_id)
        @subscriptions.delete(subscription_id)
      end

      def on_program_account_change(program_id, options = ENCODING_OPTIONS.merge(FINALIZED_OPTIONS), filters = [],
                                    &block)
        params = [program_id, options]
        params.last[:filters] = filters unless filters.empty?
        subscribe("programSubscribe", params, &block)
      end

      # Unsubscribe from program account change updates
      def remove_program_account_listener(subscription_id)
        unsubscribe("programUnsubscribe", subscription_id)
      end
    end
  end
end
