# frozen_string_literal: true

module SolanaRuby
  module HttpMethods
    # Signature Related Web Socket Methods
    module SignatureMethods
      def get_signature_statuses(signatures, options = {})
        params = [signatures, options]
        signature_request("getSignatureStatuses", params)
      end

      def get_signature_status(signature, options = {})
        signature_status = get_signature_statuses([signature], options)
        signature_status["value"].first
      end

      def get_signatures_for_address(address, options = {})
        params = [address, options]
        signature_request("getSignaturesForAddress", params)
      end

      private

      def signature_request(method, params)
        signatures_info = request(method, params)
        signatures_info["result"]
      end
    end
  end
end
