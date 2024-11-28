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
        instruction: :uint32,
        lamports: :uint64,
        space: :uint64,
        program_id: :blob32
      }
    }

    # Method to create a system account (e.g., for SPL token or SOL)
    def self.account_instruction(from_pubkey, new_account_pubkey, lamports, space, program_id)
      # Encode the instruction data
      instruction_data = encode_data(
        INSTRUCTION_LAYOUTS[:create_account],
        {
          instruction: 0,      # '0' corresponds to the Create Account instruction
          lamports: lamports,  # The amount of lamports to transfer to the new account
          space: space,        # Amount of space allocated for the account's data
          program_id: Base58.base58_to_binary(program_id, :bitcoin).bytes # Convert public key to binary
        }
      )

      # Construct the transaction instruction
      create_account_instruction = TransactionInstruction.new(
        keys: [
          { pubkey: from_pubkey, is_signer: true, is_writable: true },  # Funder's account
          { pubkey: new_account_pubkey, is_signer: true, is_writable: true } # New account
        ],
        program_id: program_id,  # Use Solana's system program for account creation
        data: instruction_data   # Encoded instruction data
      )

      # return instruction data
      create_account_instruction
    end


    def self.create_account(from_pubkey, new_account_pubkey, lamports, space, recent_blockhash, program_id = SYSTEM_PROGRAM_ID)
      # Create the transaction
      transaction = Transaction.new
      transaction.set_fee_payer(from_pubkey)
      transaction.set_recent_blockhash(recent_blockhash)

      # Add the create account instruction to the transaction
      instruction = account_instruction(from_pubkey, new_account_pubkey, lamports, space, program_id)
      transaction.add_instruction(instruction)
      
      # return the transaction for signing
      transaction
    end

    # Method to create a SOL transfer instruction
    def self.transfer_sol_instruction(from_pubkey, to_pubkey, lamports)
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
    def self.sol_transfer(from_pubkey, to_pubkey, lamports, recent_blockhash)
      transaction = Transaction.new
      transaction.set_fee_payer(from_pubkey)
      transaction.set_recent_blockhash(recent_blockhash)
      transfer_instruction = transfer_sol_instruction(from_pubkey, to_pubkey, lamports)
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
    def self.create_associated_token_account(payer, mint, owner)
      data = [0, 0, 0, 0]  # No data required for account creation
      create_account_instruction = TransactionInstruction.new(
        keys: [
          { pubkey: payer, is_signer: true, is_writable: true },
          { pubkey: associated_token, is_signer: false, is_writable: true },
          { pubkey: owner, is_signer: false, is_writable: false },
          { pubkey: mint, is_signer: false, is_writable: false },
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
