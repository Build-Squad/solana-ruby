module SolanaRuby
  class TransactionHelper
    require 'base58'
    require 'pry'

    # Constants for program IDs
    SYSTEM_PROGRAM_ID = '11111111111111111111111111111111'
    TOKEN_PROGRAM_ID = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'
    ASSOCIATED_TOKEN_PROGRAM_ID = 'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL'
    SYSVAR_RENT_ID = 'SysvarRent111111111111111111111111111111111'


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
      },
      # SPL token transfer_checked
      spl_transfer_checked: {
        instruction: :uint8,
        amount: :uint64,
        decimals: :uint8
      },
      # mint spl tokens
      spl_mint_to: {
        instruction: :uint8,
        amount: :uint64
      },
      # burn spl tokens
      spl_burn: {
        instruction: :uint8,
        amount: :uint64
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

      keys = [
        { pubkey: from_pubkey, is_signer: true, is_writable: true },  # Funder's account
        { pubkey: new_account_pubkey, is_signer: true, is_writable: true } # New account
      ]

      # return instruction data
      create_instruction(keys, instruction_data, program_id)
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
      keys = [
          { pubkey: from_pubkey, is_signer: true, is_writable: true },
          { pubkey: to_pubkey, is_signer: false, is_writable: true }
        ]

      create_instruction(keys, data, SYSTEM_PROGRAM_ID)
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
    def self.transfer_spl_token(source, token, destination, owner, amount, decimals, multi_signers)
      fields = INSTRUCTION_LAYOUTS[:spl_transfer_checked]
      data = encode_data(fields, { instruction: 12, amount: amount, decimals: decimals }) # Instruction type 3: Transfer tokens
      keys = SolanaRuby::TransactionHelpers::TokenAccount.add_signers(
        [{ pubkey: source, is_signer: false, is_writable: true },
          { pubkey: token, is_signer: false, is_writable: false },
          { pubkey: destination, is_signer: false, is_writable: true }],
          owner, multi_signers)
      
      create_instruction(keys, data)
    end

    # Helper to create a new transaction for SPL token transfer
    def self.new_spl_token_transaction(source, mint, destination, owner, amount, decimals, recent_blockhash, multi_signers=[])
      transaction = Transaction.new
      transaction.set_fee_payer(owner)
      transaction.set_recent_blockhash(recent_blockhash)
      transfer_instruction = transfer_spl_token(source, mint, destination, owner, amount, decimals, multi_signers)
      transaction.add_instruction(transfer_instruction)
      transaction
    end

    # Method to create an associated token account
    def self.create_associated_token_account(payer, mint, owner, recent_blockhash, program_id = SYSTEM_PROGRAM_ID)
      transaction = Transaction.new
      transaction.set_fee_payer(payer)  # Payer funds the transaction
      transaction.set_recent_blockhash(recent_blockhash)

      # Derive the associated token account address
      associated_token_account_pubkey = SolanaRuby::TransactionHelpers::TokenAccount.get_associated_token_address(mint, owner)
      puts "associated_token_account_pubkey: #{associated_token_account_pubkey}"

      
      # Create the associated token account instruction
      create_account_instruction = TransactionInstruction.new(
        keys: [
          { pubkey: payer, is_signer: true, is_writable: true },                 # Payer account
          { pubkey: associated_token_account_pubkey, is_signer: false, is_writable: true },  # New ATA
          { pubkey: owner, is_signer: false, is_writable: false },               # Owner of the ATA
          { pubkey: mint, is_signer: false, is_writable: false },                # Token mint
          { pubkey: SYSTEM_PROGRAM_ID, is_signer: false, is_writable: false },   # System program
          { pubkey: TOKEN_PROGRAM_ID, is_signer: false, is_writable: false },   # Token program
          { pubkey: SYSVAR_RENT_ID, is_signer: false, is_writable: false }
        ],
        program_id: ASSOCIATED_TOKEN_PROGRAM_ID,
        data: []  # No data required for creating an associated token account
      )

      # Add the instruction to the transaction
      transaction.add_instruction(create_account_instruction)
      transaction
    end

    # Method to create a mint instruction for SPL tokens
    def self.mint_spl_token(mint, destination, mint_authority, amount, multi_signers = [])
      fields = INSTRUCTION_LAYOUTS[:spl_mint_to]
      data = encode_data(fields, { instruction: 7, amount: amount }) # Instruction type 7: Mint to
      keys = SolanaRuby::TransactionHelpers::TokenAccount.add_signers(
        [{ pubkey: mint, is_signer: false, is_writable: true },
          { pubkey: destination, is_signer: false, is_writable: true }],
          mint_authority, multi_signers)

      create_instruction(keys, data)
    end

    # Helper to create a transaction for minting SPL tokens
    def self.mint_spl_tokens(mint, destination, mint_authority, amount, recent_blockhash, multi_signers = [])
      transaction = Transaction.new
      transaction.set_fee_payer(mint_authority)
      transaction.set_recent_blockhash(recent_blockhash)
      mint_instruction = mint_spl_token(mint, destination, mint_authority, amount, multi_signers)
      transaction.add_instruction(mint_instruction)
      transaction
    end

    # Method to create a burn instruction for SPL tokens
    def self.burn_spl_token(token_account, mint, mint_authority, amount, multi_signers = [])
      # Define the fields for the burn instruction
      fields = INSTRUCTION_LAYOUTS[:spl_burn]
      
      # Encode the instruction data
      data = encode_data(fields, { instruction: 8, amount: amount }) # Instruction type 8: Burn

      keys = SolanaRuby::TransactionHelpers::TokenAccount.add_signers(
        [
          { pubkey: token_account, is_signer: false, is_writable: true }, # Token account holding tokens to burn
          { pubkey: mint, is_signer: false, is_writable: true }          # Mint address
        ], mint_authority, multi_signers)

      # Return the transaction instruction
      create_instruction(keys, data)
    end

    # Helper to create a transaction for burning SPL tokens
    def self.burn_spl_tokens(token_account, mint, owner, amount, recent_blockhash, multi_signers = [])
      # Create a new transaction
      transaction = Transaction.new
      transaction.set_fee_payer(owner)
      transaction.set_recent_blockhash(recent_blockhash)

      # Add the burn instruction to the transaction
      burn_instruction = burn_spl_token(token_account, mint, owner, amount, multi_signers)
      transaction.add_instruction(burn_instruction)

      # Return the transaction for signing
      transaction
    end

    # Derive the associated token account address
    def self.get_associated_token_address(mint, owner, program_id)
      SolanaRuby::TransactionHelpers::TokenAccount.get_associated_token_address(mint, owner, program_id)
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

    def self.create_instruction(keys, data, toke_program_id = TOKEN_PROGRAM_ID)
      TransactionInstruction.new(
        keys: keys,
        program_id: toke_program_id,
        data: data
      )
    end
  end
end
