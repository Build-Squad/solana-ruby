module SolanaRuby
  class TransactionHelper
    require 'base58'
    PROGRAM_ID = '11111111111111111111111111111111'
    INSTRUCTION_LAYOUTS = {
      # transfer
      2 => {
        instruction: :uint32,
        lamports: :near_int64
      }
    }

    def self.create_transfer(from_pubkey, to_pubkey, lamports, program_id = PROGRAM_ID)
      fields = INSTRUCTION_LAYOUTS[2]
      data = encode_data(fields, { instruction: 2, lamports: lamports })
      transfer_instruction = TransactionInstruction.new(
        keys: [
          { pubkey: from_pubkey, is_signer: true, is_writable: true },
          { pubkey: to_pubkey, is_signer: false, is_writable: true }
        ],
        program_id: program_id,
        data: data # [2, lamports].pack('CQ<')  # Instruction type 2 (transfer) + lamports (u64)
      )
      transfer_instruction
    end

    # Helper to construct a new transaction
    def self.new_transaction(from_pubkey, to_pubkey, lamports, recent_blockhash, program_id = PROGRAM_ID)
      transaction = Transaction.new
      transaction.set_fee_payer(from_pubkey)
      transaction.set_recent_blockhash(recent_blockhash)

      transfer_instruction = create_transfer(from_pubkey, to_pubkey, lamports, program_id)
      transaction.add_instruction(transfer_instruction)
      transaction
    end

    def self.encode_data(fields, data)
      layout = SolanaRuby::DataTypes::Layout.new(fields)
      layout.serialize(data)
    end

    def self.decode_data(fields, data)
      layout = SolanaRuby::DataTypes::Layout.new(fields)
      layout.deserialize(data)
    end
  end
end
