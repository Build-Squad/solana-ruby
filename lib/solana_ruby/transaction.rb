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
      unless Base58.valid?(pubkey)
        raise "Invalid Base58 public key for fee payer: #{pubkey.inspect}"
      end
      @fee_payer = pubkey  # Store as-is since Base58 gem can handle encoding/decoding
    end

    def set_recent_blockhash(blockhash)
      raise "Invalid Base58 blockhash" unless Base58.valid?(blockhash)
      @recent_blockhash = blockhash  # Store as-is for similar reasons
    end

    def serialize
      raise "Recent blockhash not set" if @recent_blockhash.nil?
      raise "Fee payer not set" if @fee_payer.nil?

      transaction_data = []
      transaction_data << Base58.base58_to_binary(@recent_blockhash)  # Convert as needed here
      transaction_data << Base58.base58_to_binary(@fee_payer)
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

      @signatures << signature  # Store as binary
      Base58.binary_to_base58(signature)  # Convert to Base58 for external use
    end

    private

    def serialize_message
      accounts = collect_accounts

      message_data = []
      message_data << Base58.base58_to_binary(@recent_blockhash)
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
      accounts << Base58.base58_to_binary(@fee_payer) if @fee_payer

      @instructions.each do |instruction|
        instruction.keys.each do |key_meta|
          pubkey_binary = Base58.base58_to_binary(key_meta[:pubkey])
          accounts << pubkey_binary unless accounts.include?(pubkey_binary)
        end
      end

      accounts.uniq
    end
  end
end

class Base58
  ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'.freeze

  # Checks if a string contains only valid Base58 characters
  def self.valid?(base58_str)
    base58_str.chars.all? { |char| ALPHABET.include?(char) }
  end
end
