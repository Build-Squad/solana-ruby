module SolanaRuby
  class TransactionHelper
    require 'base58'
    require 'pry'

    # Constants for program IDs
    SYSTEM_PROGRAM_ID = '11111111111111111111111111111111'
    TOKEN_PROGRAM_ID = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'
    ASSOCIATED_TOKEN_PROGRAM_ID = 'ATokenGP3evbxxpQ7bYPLNNaxD2c4bqtvWjpKbmz6HjH'

    INSTRUCTION_LAYOUTS = {
      # Native SOL transfer
      sol_transfer: {
        instruction: :uint32,
        lamports: :near_int64
      },
      # SPL token transfer
      spl_transfer: {
        instruction: :uint8,
        amount: :uint64
      },
       # Create account layout
      create_account: {
        instruction: :uint8,
        lamports: :uint64,
        space: :uint64
      }
    }

    # Method to create a system account (e.g., for SPL token or SOL)
    def self.create_account(from_pubkey, new_account_pubkey, lamports, space, owner_pubkey = SYSTEM_PROGRAM_ID)
      instruction_data = encode_data(INSTRUCTION_LAYOUTS[:create_account], { instruction: 0, lamports: lamports, space: space })
      create_account_instruction = TransactionInstruction.new(
        keys: [
          { pubkey: from_pubkey, is_signer: true, is_writable: true },
          { pubkey: new_account_pubkey, is_signer: false, is_writable: true },
          { pubkey: owner_pubkey, is_signer: false, is_writable: false }
        ],
        program_id: owner_pubkey,
        data: instruction_data.bytes
      )
      create_account_instruction
    end

    def self.create_and_sign_transaction(from_pubkey, new_account_pubkey, lamports, space, recent_blockhash)
      # Create the transaction
      transaction = Transaction.new
      transaction.set_fee_payer(from_pubkey)
      transaction.set_recent_blockhash(recent_blockhash)

      # Add the create account instruction to the transaction
      create_account_instruction = create_account(from_pubkey, new_account_pubkey, lamports, space)
      transaction.add_instruction(create_account_instruction)

      # You would then sign the transaction and send it as needed
      # Example: signing and sending the transaction
      transaction
    end

    # Method to create a SOL transfer instruction
    def self.transfer_sol_transaction(from_pubkey, to_pubkey, lamports)
      fields = INSTRUCTION_LAYOUTS[:sol_transfer]
      data = encode_data(fields, { instruction: 2, lamports: lamports })
      TransactionInstruction.new(
        keys: [
          { pubkey: from_pubkey, is_signer: true, is_writable: true },
          { pubkey: to_pubkey, is_signer: false, is_writable: true }
        ],
        program_id: SYSTEM_PROGRAM_ID,
        data: data
      )
    end

    # Helper to create a new transaction for SOL transfer
    def self.new_sol_transaction(from_pubkey, to_pubkey, lamports, recent_blockhash)
      transaction = Transaction.new
      transaction.set_fee_payer(from_pubkey)
      transaction.set_recent_blockhash(recent_blockhash)
      transfer_instruction = transfer_sol_transaction(from_pubkey, to_pubkey, lamports)
      transaction.add_instruction(transfer_instruction)
      transaction
    end

    # Method to create an SPL token transfer instruction
    def self.transfer_spl_token(source, destination, owner, amount)
      fields = INSTRUCTION_LAYOUTS[:spl_transfer]
      data = encode_data(fields, { instruction: 3, amount: amount }) # Instruction type 3: Transfer tokens
      TransactionInstruction.new(
        keys: [
          { pubkey: source, is_signer: false, is_writable: true },
          { pubkey: destination, is_signer: false, is_writable: true },
          { pubkey: owner, is_signer: true, is_writable: false }
        ],
        program_id: TOKEN_PROGRAM_ID,
        data: data
      )
    end

    # Helper to create a new transaction for SPL token transfer
    def self.new_spl_token_transaction(source, destination, owner, amount, recent_blockhash)
      transaction = Transaction.new
      transaction.set_fee_payer(owner)
      transaction.set_recent_blockhash(recent_blockhash)
      transfer_instruction = transfer_spl_token(source, destination, owner, amount)
      transaction.add_instruction(transfer_instruction)
      transaction
    end

    # Method to create an associated token account for a given token mint
    def self.create_associated_token_account(from_pubkey, token_mint, owner_pubkey)
      data = [0, 0, 0, 0]  # No data required for account creation
      create_account_instruction = TransactionInstruction.new(
        keys: [
          { pubkey: from_pubkey, is_signer: true, is_writable: true },
          { pubkey: owner_pubkey, is_signer: false, is_writable: true },
          { pubkey: token_mint, is_signer: false, is_writable: false },
          { pubkey: ASSOCIATED_TOKEN_PROGRAM_ID, is_signer: false, is_writable: false },
          { pubkey: SYSTEM_PROGRAM_ID, is_signer: false, is_writable: false }
        ],
        program_id: ASSOCIATED_TOKEN_PROGRAM_ID,
        data: data
      )
      create_account_instruction
    end

    # Utility to encode data using predefined layouts
    def self.encode_data(fields, data)
      layout = SolanaRuby::DataTypes::Layout.new(fields)
      layout.serialize(data)
    end

    # Utility to decode data using predefined layouts
    def self.decode_data(fields, data)
      layout = SolanaRuby::DataTypes::Layout.new(fields)
      layout.deserialize(data)
    end
  end
end
