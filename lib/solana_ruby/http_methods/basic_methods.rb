# frozen_string_literal: true

module SolanaRuby
  module HttpMethods
    module BasicMethods

      def get_balance(pubkey)
        request("getBalance", [pubkey])
      end

      def get_recent_blockhash
        request("getRecentBlockhash")
      end
    end
  end
end
