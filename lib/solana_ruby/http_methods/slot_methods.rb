# frozen_string_literal: true

module SolanaRuby
  module HttpMethods
    # Slot Related HTTP Methods
    module SlotMethods
      def get_slot
        slot_info = request("getSlot")
        slot_info["result"]
      end

      def get_slot_leader(options = {})
        slot_leader = request("getSlotLeader", [options])
        slot_leader["result"]
      end

      def get_slot_leaders(start_slot, limit)
        params = [start_slot, limit]
        slot_leaders = request("getSlotLeaders", params)
        slot_leaders["result"]
      end

      def get_highest_snapshot_slot
        slot_leaders = request("getHighestSnapshotSlot")
        slot_leaders["result"]
      end

      def get_minimum_ledger_slot
        minimum_ladger_slot = request("minimumLedgerSlot")
        minimum_ladger_slot["result"]
      end

      def get_max_retransmit_slot
        max_retransmit_slot = request("getMaxRetransmitSlot")
        max_retransmit_slot["result"]
      end

      def get_max_shred_insert_slot
        max_shred_insert_slot = request("getMaxShredInsertSlot")
        max_shred_insert_slot["result"]
      end
    end
  end
end
