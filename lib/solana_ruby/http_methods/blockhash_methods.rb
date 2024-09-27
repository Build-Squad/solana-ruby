# frozen_string_literal: true

module SolanaRuby
  module HttpMethods
    # Blockhash Related HTTP Methods
    module BlockhashMethods
      def get_latest_blockhash
        recent_blockhash_info = get_latest_blockhash_and_context
        recent_blockhash_info["value"]
      end

      def get_latest_blockhash_and_context
        recent_blockhash_info = request("getLatestBlockhash")
        recent_blockhash_info["result"]
      end

      def get_fee_for_message(blockhash, options = { commitment: "processed" })
        params = [blockhash, options]
        fee_for_blockhash_info = request("getFeeForMessage", params)
        fee_for_blockhash_info["result"]
      end

      def is_blockhash_valid?(blockhash, options = { commitment: "processed" })
        params = [blockhash, options]
        blockhash_info = request("isBlockhashValid", params)
        blockhash_info["result"]["value"]
      end
    end
  end
end
