module SolanaRuby
  class Keypair
    require 'rbnacl'
    require 'base58'

    # Generates a new Ed25519 keypair
    def self.generate
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.generate
      private_key_bytes = signing_key.to_bytes

      keys(signing_key, private_key_bytes)
    end

    # Restores a keypair from a private key in hex format
    def self.from_private_key(private_key_hex)
      raise ArgumentError, "Invalid private key length" unless private_key_hex.size == 64

      # Convert hex private key to binary format for signing key
      private_key_bytes = [private_key_hex].pack('H*')

      # Initialize signing key
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.new(private_key_bytes)

      keys(signing_key, private_key_bytes)
    end

    # Load a keypair from a JSON file
    def self.load_keypair(file_path)
      # Parse the JSON file
      keypair_data = JSON.parse(File.read(file_path))

      # Ensure it contains exactly 64 bytes for Ed25519 (32 private + 32 public)
      raise "Invalid keypair length: expected 64 bytes, got #{keypair_data.length}" unless keypair_data.length == 64

      # Convert the array to a binary string
      private_key_bytes = keypair_data[0, 32].pack('C*')
      public_key_bytes = keypair_data[32, 32].pack('C*')

      # Create the signing key
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.new(private_key_bytes)

      # Verify the public key matches
      raise "Public key mismatch" unless signing_key.verify_key.to_bytes == public_key_bytes

      keys(signing_key, private_key_bytes)
    rescue JSON::ParserError => e
      raise "Failed to parse JSON file: #{e.message}"
    end


    private

    def self.keys(signing_key, private_key_bytes)
      # Extract public key in binary format
      public_key_bytes = signing_key.verify_key.to_bytes
      private_key_hex = private_key_bytes.unpack1('H*') # Hex format for private key

      # Return public key in Base58 format and private key in hex format
      {
        public_key: Base58.binary_to_base58(public_key_bytes, :bitcoin),
        private_key: private_key_hex,
        full_private_key: Base58.binary_to_base58((private_key_bytes + public_key_bytes), :bitcoin)
      }
    end
  end
end
