module SolanaRuby
  module TransactionHelpers
    class TokenAccount
      # Associated Token Program ID
      ASSOCIATED_TOKEN_PROGRAM_ID = 'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL'.freeze

      # Token Program ID
      TOKEN_PROGRAM_ID = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'.freeze

      def self.get_associated_token_address(mint, payer)
        mint_bytes = Base58.base58_to_binary(mint, :bitcoin)
        payer_bytes = Base58.base58_to_binary(payer, :bitcoin)
        associated_program_bytes = Base58.base58_to_binary(ASSOCIATED_TOKEN_PROGRAM_ID, :bitcoin)

        # Derive associated token account PDA
        seeds = [
          payer_bytes,
          Base58.base58_to_binary(TOKEN_PROGRAM_ID, :bitcoin),
          mint_bytes
        ]
        
        # Attempt to find the first valid off-curve PDA
        associated_token_account_pubkey = find_program_address(seeds, associated_program_bytes)

        # Return the computed Base58 PDA string
        Base58.binary_to_base58(associated_token_account_pubkey, :bitcoin)
      end

      def self.add_signers(keys, owner_or_authority, multi_signers)
        if multi_signers.is_a?(Array) && multi_signers.any?
          keys.push({ pubkey: owner_or_authority, is_signer: false, is_writable: false })
          multi_signers.each do |signer|
            pubkey = signer.is_a?(String) ? signer : signer.public_key
            keys.push({ pubkey: pubkey, is_signer: true, is_writable: false })
          end
        else
          keys.push({ pubkey: owner_or_authority, is_signer: true, is_writable: false })
        end
        keys
      end

      private

      def self.find_program_address(seeds, program_id)
        nonce = 255
        loop do
          # Combine the current nonce with the seeds
          seeds_with_nonce = seeds + [[nonce].pack('C*')]
          hashed_buffer = hash_seeds(seeds_with_nonce, program_id)

          # Debugging: Log every generated address for inspection
          puts "Testing nonce #{nonce}: #{Base58.binary_to_base58(hashed_buffer, :bitcoin)}"

          # Check if it's valid and off-curve
          if !SolanaRuby::Ed25519CurveChecker.on_curve?(hashed_buffer)
            puts "Found valid PDA with nonce #{nonce}: #{Base58.binary_to_base58(hashed_buffer, :bitcoin)}"
            return hashed_buffer
          end

          # Decrement nonce safely
          nonce -= 1
          raise "Unable to find a valid PDA address off the curve" if nonce < 0
        end
      end

      def self.hash_seeds(seeds, program_id)
        # Combine seeds and program ID with the PDA derivation logic
        buffer = seeds.flatten.join + program_id + "ProgramDerivedAddress"
        RbNaCl::Hash.sha256(buffer)
      end
    end
  end
end
