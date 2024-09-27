# frozen_string_literal: true

module SolanaRuby
  module HttpMethods
    # Block Related HTTP Methods
    module BlockMethods
      DEFAULT_OPTIONS = { maxSupportedTransactionVersion: 0 }.freeze

      def get_blocks(start_slot, end_slot)
        params = [start_slot, end_slot]
        block_info = request("getBlocks", params)
        block_info["result"]
      end

      def get_block(slot, options = DEFAULT_OPTIONS)
        params = [slot, options]
        block_info = request("getBlock", params)
        block_info["result"]
      end

      def get_block_production
        request("getBlockProduction")
      end

      def get_block_time(slot)
        block_info = request("getBlockTime", [slot])
        block_info["result"]
      end

      def get_block_signatures(slot, options = DEFAULT_OPTIONS)
        block_info = get_block(slot, options)
        block_signatures(block_info)
      end

      def get_cluster_nodes
        cluster_nodes_info = request("getClusterNodes")
        cluster_nodes_info["result"]
      end

      def get_confirmed_block(slot, options = DEFAULT_OPTIONS)
        block_info = get_block(slot, options)
        block_info["result"]
      end

      def get_confirmed_block_signatures(slot)
        block_info = get_confirmed_block(slot)
        block_signatures(block_info)
      end

      def get_parsed_block(slot, options = {})
        params = [slot, { encoding: "jsonParsed", transactionDetails: "full" }.merge(options)]
        result = request("getBlock", params)
        result["result"]
      end

      def get_first_available_block
        result = request("getFirstAvailableBlock")
        result["result"]
      end

      def get_blocks_with_limit(start_slot, limit)
        params = [start_slot, limit]
        response = request("getBlocksWithLimit", params)
        response["result"]
      end

      def get_block_height
        block_height = request("getBlockHeight")
        block_height["result"]
      end

      def get_block_commitment(block_slot)
        block_commitment = request("getBlockCommitment", [block_slot])
        block_commitment["result"]
      end

      private

      def block_signatures(block_info)
        signatures = block_info["transactions"][0]["transaction"]["signatures"]
        block_info.delete("transactions")
        block_info.delete("rewards")
        block_info.merge({
                           signatures: signatures
                         })
      end
    end
  end
end
