# frozen_string_literal: true

module SolanaRuby
  module HttpMethods
    module BlockhashMethods

      def get_latest_blockhash
        recent_blockhash_info = get_latest_blockhash_and_context
        recent_blockhash_info['value']
      end

      def get_latest_blockhash_and_context
        recent_blockhash_info = request('getLatestBlockhash')
        recent_blockhash_info['result']
      end

      def get_fee_calculator_for_blockhash(block_hash, options = { commitment: 'finalized' })
        params = [block_hash, options]
        free_calculator_for_blockhash_info = request('getFeeCalculatorForBlockhash', params)
        free_calculator_for_blockhash_info['result']
      end
    end
  end
end
