module SolanaRuby
  class TransactionInstruction
    attr_accessor :keys, :program_id, :data

    def initialize(keys:, program_id:, data:)
      @keys = keys      # An array of account meta objects
      @program_id = program_id  # The program this instruction interacts with
      @data = data       # The binary data (or base64) for the instruction
    end

    def serialize
      serialized_instruction = ""

      # Serialize the program ID (ensure it's in binary form)
      serialized_instruction << Base58.binary_to_base58(@program_id)

      # Serialize the number of keys
      serialized_instruction << [@keys.length].pack("C")

      # Serialize each key (pubkey, is_signer, is_writable)
      @keys.each do |key_meta|
        serialized_instruction << Base58.base58_to_binary(key_meta[:pubkey])  # Ensure it's in binary
        meta_flags = (key_meta[:is_signer] ? 1 : 0) | (key_meta[:is_writable] ? 2 : 0)
        serialized_instruction << [meta_flags].pack("C")
      end

      # Serialize the length of the data
      serialized_instruction << [@data.length].pack("C")

      # Add the data itself (ensure it's in binary form)
      serialized_instruction << @data

      serialized_instruction
    end
  end
end
