# frozen_string_literal: true

module SolanaRuby
  module HttpMethods
    module BlockhashMethods

      def get_recent_blockhash
        recent_blockhash_info = request("getLatestBlockhash")
        recent_blockhash_info["result"]["value"]
      end
    end
  end
end
