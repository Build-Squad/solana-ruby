module SolanaRuby
  class TransactionInstruction
    require 'base58'

    attr_accessor :keys, :program_id, :data

    def initialize(keys:, program_id:, data:)
      @keys = keys           # Array of account metadata hashes
      @program_id = program_id  # Program ID in Base58
      @data = data           # Binary data for the instruction
    end

    def serialize
      serialized_instruction = ""

      # Convert and serialize the program ID from Base58 to binary
      program_id_binary = Base58.base58_to_binary(@program_id)
      serialized_instruction << program_id_binary

      # Serialize the number of keys
      serialized_instruction << [@keys.length].pack("C")

      # Serialize each key (pubkey in binary, is_signer, is_writable flags)
      @keys.each do |key_meta|
        # Convert public key to binary and serialize it
        pubkey_binary = Base58.base58_to_binary(key_meta[:pubkey])
        serialized_instruction << pubkey_binary

        # Serialize meta flags (is_signer and is_writable)
        meta_flags = (key_meta[:is_signer] ? 1 : 0) | (key_meta[:is_writable] ? 2 : 0)
        serialized_instruction << [meta_flags].pack("C")
      end

      # Serialize data length (encoded as a single byte, can adjust with C, S, and L accordingly if data is larger)
      serialized_instruction << [@data.length].pack("C")

      # Serialize the actual data in binary format
      serialized_instruction << @data
      serialized_instruction
    end
  end
end
