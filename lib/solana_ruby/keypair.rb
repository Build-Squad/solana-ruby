module SolanaRuby
  class Keypair
    require 'rbnacl'
    require 'base58'

    def self.generate
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.generate
      public_key_bytes = signing_key.verify_key.to_bytes # Ensure it's in binary format
      private_key_hex = signing_key.to_bytes.unpack1('H*') # Hex format for the private key

      # Convert public key binary to Base58
      { public_key: Base58.binary_to_base58(public_key_bytes), private_key: private_key_hex }
    end

    def self.from_private_key(private_key_hex)
      # Convert the hex private key to binary
      private_key_bytes = [private_key_hex].pack('H*')

      # Create a signing key using the binary private key
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.new(private_key_bytes)

      # Extract the public key as bytes (raw binary)
      public_key_bytes = signing_key.verify_key.to_bytes

      # Return both the public key in Base58 and the private key in hex
      { public_key: Base58.binary_to_base58(public_key_bytes), private_key: private_key_hex }
    end
  end
end
