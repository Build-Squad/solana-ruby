module SolanaRuby
  class Transaction
    require 'rbnacl'

    attr_accessor :instructions, :signatures, :fee_payer, :recent_blockhash

    def initialize
      @instructions = []
      @signatures = []
      @fee_payer = nil
      @recent_blockhash = nil
    end

    def add_instruction(instruction)
      @instructions << instruction
    end

    def set_fee_payer(pubkey)
      puts "Setting fee payer: #{pubkey.inspect}"  # Debugging output
      if Base58.valid?(pubkey)
        @fee_payer = Base58.base58_to_binary(pubkey) # Ensure it uses the binary version
      else
        raise "Invalid Base58 public key for fee payer: #{pubkey.inspect}"
      end
    end

    def set_recent_blockhash(blockhash)
      raise "Invalid Base58 blockhash" unless Base58.valid?(blockhash)
      @recent_blockhash = Base58.base58_to_binary(blockhash) # Convert to binary format
    end

    def serialize
      raise "Recent blockhash not set" if @recent_blockhash.nil?
      raise "Fee payer not set" if @fee_payer.nil?

      transaction_data = []
      transaction_data << @recent_blockhash
      transaction_data << @fee_payer
      transaction_data << [@instructions.length].pack("C")

      @instructions.each do |instruction|
        serialized_instruction = instruction.serialize
        raise "Instruction serialization failed" if serialized_instruction.nil?

        transaction_data << serialized_instruction
      end

      serialized = transaction_data.join
      puts "Serialized Transaction Data: #{serialized.bytes.inspect}"  # Debugging output

      serialized
    end

    def sign(private_key_hex)
      private_key_bytes = [private_key_hex].pack('H*')
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.new(private_key_bytes)

      message = serialize_message
      signature = signing_key.sign(message)

      @signatures << signature
      Base58.binary_to_base58(signature)
    end

    def deserialize(data)
      transaction = new

      # Read recent blockhash
      transaction.recent_blockhash = data[0..31]  # Assuming 32 bytes for the blockhash

      # Read fee payer
      transaction.fee_payer = data[32..63]  # Assuming 32 bytes for the fee payer

      # Read number of instructions
      num_instructions = data[64].unpack1('C')  # Assuming a single byte for count

      offset = 65  # Start reading instructions after fee payer and instruction count

      num_instructions.times do
        instruction, offset = TransactionInstruction.deserialize(data, offset)
        transaction.instructions << instruction
      end

      transaction
    end

    private

    def serialize_message
      accounts = collect_accounts

      message_data = []
      message_data << @recent_blockhash
      message_data << [accounts.length].pack("C")

      accounts.each do |account|
        message_data << account
      end

      message_data << [@instructions.length].pack("C")

      @instructions.each do |instruction|
        message_data << instruction.serialize
      end

      message_data.join
    end

    def collect_accounts
      accounts = []
      accounts << @fee_payer if @fee_payer

      @instructions.each do |instruction|
        instruction.keys.each do |key_meta|
          pubkey = Base58.base58_to_binary(key_meta[:pubkey]) # Ensure binary
          accounts << pubkey unless accounts.include?(pubkey)
        end
      end

      accounts.uniq
    end
  end
end

class Base58
  ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'.freeze

  def self.valid?(base58_str)
    # Check if the string contains only valid Base58 characters
    base58_str.chars.all? { |char| ALPHABET.include?(char) }
  end
end
