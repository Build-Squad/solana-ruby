module SolanaRuby
  class TransactionInstruction
    attr_accessor :keys, :program_id, :data

    def initialize(keys:, program_id:, data:)
      @keys = keys      # An array of account meta objects
      @program_id = program_id  # The program this instruction interacts with
      @data = data       # The binary data (or base64) for the instruction
    end

    # Serialize the instruction into a binary format for a Solana transaction
    def serialize
      serialized_instruction = ""

      # 1. Serialize the program ID
      serialized_instruction << @program_id

      # 2. Serialize the number of keys
      serialized_instruction << [@keys.length].pack("C")

      # 3. Serialize each key (pubkey, is_signer, is_writable)
      @keys.each do |key_meta|
        serialized_instruction << key_meta[:pubkey]
        meta_flags = (key_meta[:is_signer] ? 1 : 0) | (key_meta[:is_writable] ? 2 : 0)
        serialized_instruction << [meta_flags].pack("C")
      end

      # 4. Serialize the length of the data
      serialized_instruction << [@data.length].pack("C")

      # 5. Add the data itself (ensure it's in binary form)
      serialized_instruction << @data

      serialized_instruction
    end
  end
end
