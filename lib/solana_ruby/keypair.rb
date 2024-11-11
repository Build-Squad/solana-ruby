module SolanaRuby
  class Keypair
    require 'rbnacl'
    require 'base58'

    # Generates a new Ed25519 keypair
    def self.generate
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.generate
      public_key_bytes = signing_key.verify_key.to_bytes # Binary format for public key
      private_key_hex = signing_key.to_bytes.unpack1('H*') # Hex format for private key

      # Convert public key binary to Base58 for readability and compatibility
      {
        public_key: Base58.binary_to_base58(public_key_bytes),
        private_key: private_key_hex
      }
    end

    # Restores a keypair from a private key in hex format
    def self.from_private_key(private_key_hex)
      raise ArgumentError, "Invalid private key length" unless private_key_hex.size == 64

      # Convert hex private key to binary format for signing key
      private_key_bytes = [private_key_hex].pack('H*')

      # Initialize signing key
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.new(private_key_bytes)

      # Extract public key in binary format
      public_key_bytes = signing_key.verify_key.to_bytes

      # Return public key in Base58 format and private key in hex format
      {
        public_key: Base58.binary_to_base58(public_key_bytes),
        private_key: private_key_hex
      }
    end
  end
end
