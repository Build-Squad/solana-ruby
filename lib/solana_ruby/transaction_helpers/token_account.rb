module SolanaRuby
  module TransactionHelpers
    class TokenAccount

      # Associated Token Program ID
      ASSOCIATED_TOKEN_PROGRAM_ID = 'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL'.freeze

      # Token Program ID
      TOKEN_PROGRAM_ID = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'.freeze

      MAX_SEED_LENGTH = 32

      def self.to_buffer(input, length: MAX_SEED_LENGTH, endian: :be)
        case input
        when SolanaRuby::PublicKey
          buffer = input.to_bytes
        when String
          buffer = input.bytes.pack('C*') # String to binary
        when Array
          buffer = input.pack('C*') # Array to binary
        when Integer
          buffer = [input].pack(endian == :le ? 'V*' : 'N*') # Integer to binary
        else
          raise ArgumentError, "Unsupported input type: #{input.class}"
        end

        # Zero-pad or truncate to ensure desired length
        if buffer.bytesize < length
          padding = "\x00" * (length - buffer.bytesize)
          endian == :le ? buffer + padding : padding + buffer
        elsif buffer.bytesize > length
          raise ArgumentError, "Input exceeds desired length of #{length} bytes"
        else
          buffer
        end
      end


      # Calculate the associated token account address
      def self.get_associated_token_address(mint, owner, program_id = TOKEN_PROGRAM_ID)
        # Convert public keys to binary
        payer_bytes = to_buffer(SolanaRuby::PublicKey.new(owner))       # Payer public key
        mint_bytes = to_buffer(SolanaRuby::PublicKey.new(mint))         # Token mint address
        program_id_bytes = to_buffer(SolanaRuby::PublicKey.new(program_id)) # Token Program ID
        associated_program_bytes = to_buffer(SolanaRuby::PublicKey.new(ASSOCIATED_TOKEN_PROGRAM_ID))

        # Use `create_program_address` to derive the associated token account
        associated_token_account_pubkey = create_program_address_sync(
          [
            payer_bytes,
            program_id_bytes,  # Using the associated token program ID here
            mint_bytes
          ],
          associated_program_bytes
        )

        # Return the associated token account in Base58 format
        Base58.binary_to_base58(associated_token_account_pubkey, :bitcoin)
      end

      # Method to create program address synchronously
      def self.create_program_address_sync(seeds, associated_program_bytes)
        nonce = 255
        loop do
          seeds_with_nonce = seeds + [[nonce].pack('C*')]

          buffer = seeds_with_nonce.join.b
          buffer << associated_program_bytes
          buffer << 'ProgramDerivedAddress'.b
          hashed_buffer = RbNaCl::Hash.sha256(buffer)
          puts "generated address #{nonce}: #{Base58.binary_to_base58(hashed_buffer, :bitcoin)}"

          unless on_curve?(hashed_buffer)
            return hashed_buffer
          end

          nonce -= 1
          raise 'Unable to find a viable program address nonce' if nonce < 0
        end
      end

      # Method to check if a public key is on the Ed25519 curve
      def self.on_curve?(public_key_bytes)
        return false unless public_key_bytes.bytesize == 32 # Must be 32 bytes

        # Curve25519 parameters
        p = 2**255 - 19 # Prime field for Curve25519
        a = 486662      # Curve parameter

        # Interpret the public key as an integer (little-endian format for Curve25519)
        x = public_key_bytes.unpack1('C*').reverse.pack('C*').unpack1('H*').to_i(16) # Convert to integer

        # Calculate y² = x³ + 486662x² + x (mod p)
        x_squared = (x * x) % p
        x_cubed = (x_squared * x) % p
        y_squared = (x_cubed + (a * x_squared) + x) % p

        # Check if y² is a quadratic residue modulo p
        legendre_symbol = y_squared.pow((p - 1) / 2, p)
        legendre_symbol == 1 # Valid point if legendre symbol equals 1
      rescue StandardError
        false # Invalid public key format
      end
    end
  end
end
