# frozen_string_literal: true

module SolanaRuby
  module WebSocketMethods
    # Signature Related Web Socket Methods
    module SignatureMethods
      FINALIZED_OPTIONS = { commitment: "finalized" }.freeze
      BASE_64_ENCODING_OPTIONS = { encoding: "base64" }.freeze

      def on_signature(signature, options = FINALIZED_OPTIONS, &block)
        params = [signature, options]
        subscribe("signatureSubscribe", params, &block)
      end

      def on_signature_with_options(signature, options = BASE_64_ENCODING_OPTIONS.merge(FINALIZED_OPTIONS), &block)
        on_signature(signature, options, &block)
      end

      # Unsubscribe from signature updates
      def remove_signature_listener(subscription_id)
        unsubscribe("signatureUnsubscribe", subscription_id)
      end
    end
  end
end
