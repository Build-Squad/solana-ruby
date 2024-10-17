module SolanaRuby
  class TransactionHelper
    require 'base58'
    PROGRAM_ID = '11111111111111111111111111111111'

    def self.create_transfer(from_pubkey, to_pubkey, lamports, program_id = PROGRAM_ID)
      transfer_instruction = TransactionInstruction.new(
        keys: [
          { pubkey: from_pubkey, is_signer: true, is_writable: true },
          { pubkey: to_pubkey, is_signer: false, is_writable: true }
        ],
        program_id: Base58.base58_to_binary(program_id),  # Decode for transaction
        data: [2, lamports].pack('CQ<')  # Instruction type 2 (transfer) + lamports (u64)
      )
      transfer_instruction
    end

    # Helper to construct a new transaction
    def self.new_transaction(from_pubkey, to_pubkey, lamports, recent_blockhash, program_id)
      transaction = Transaction.new
      transaction.set_fee_payer(from_pubkey)
      transaction.set_recent_blockhash(recent_blockhash)

      transfer_instruction = create_transfer(from_pubkey, to_pubkey, lamports, program_id)
      transaction.add_instruction(transfer_instruction)
      transaction
    end
  end
end
