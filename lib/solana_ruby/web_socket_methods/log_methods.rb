# frozen_string_literal: true

module SolanaRuby
  module WebSocketMethods
    # Log Related Web Socket Methods
    module LogMethods
      def on_logs(params = ["all"], &block)
        subscribe("logsSubscribe", params, &block)
      end

      def on_logs_for_account(public_key, &block)
        params = [{ mentions: [public_key] }]
        on_logs(params, &block)
      end

      def on_logs_for_program(program_id, &block)
        params = [{ mentions: [program_id] }]
        on_logs(params, &block)
      end

      # Unsubscribe from logs updates
      def remove_logs_listener(subscription_id)
        unsubscribe("logsUnsubscribe", subscription_id)
      end
    end
  end
end
