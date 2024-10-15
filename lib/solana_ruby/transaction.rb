module SolanaRuby
  class Transaction
    require 'base58'
    require 'rbnacl'
    
    attr_accessor :instructions, :signatures, :fee_payer, :recent_blockhash

    def initialize
      @instructions = []
      @signatures = []
      @fee_payer = nil
      @recent_blockhash = nil
    end

    # Add an instruction to the transaction
    def add_instruction(instruction)
      @instructions << instruction
    end

    # Set the fee payer for the transaction
    def set_fee_payer(pubkey)
      @fee_payer = pubkey
    end

    # Set the recent blockhash
    def set_recent_blockhash(blockhash)
      @recent_blockhash = blockhash
    end

    # Serialize the transaction for sending to Solana RPC
    def serialize
      all_accounts = collect_accounts
      message = serialize_message(all_accounts)

      # Add signatures to the message (if any)
      signature_block = @signatures.map { |sig| sig.nil? ? "\x00" * 64 : sig }.join

      signature_block + message
    end

    # Sign the transaction using the private key
    def sign(private_key_hex)
      private_key_bytes = [private_key_hex].pack('H*')
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.new(private_key_bytes)

      # Serialize the message without signatures to sign it
      message = serialize_message(collect_accounts)

      # Sign the serialized message
      signature = signing_key.sign(message)

      # Attach the signature
      @signatures << signature
    end

    private



def collect_accounts
  accounts = []

  # Add the fee payer if set
  if @fee_payer
    puts "Fee Payer: #{@fee_payer.inspect} (Size: #{@fee_payer.bytesize})"  # Debugging output
    accounts << @fee_payer
  end

  @instructions.each do |instruction|
    instruction.keys.each do |key_meta|
      pubkey = key_meta[:pubkey]
      puts "Adding account: #{pubkey.inspect} (Size: #{pubkey.bytesize})"  # Debugging output

      # Decode from Base58 if necessary
      if pubkey.is_a?(String) && pubkey.length == 44  # Base58 string length check
        pubkey = Base58.decode(pubkey)
      end

      # Validate account size
      raise "Invalid account size" unless pubkey.bytesize == 32

      accounts << pubkey
    end
  end

  accounts.uniq!
end

    def serialize_message(accounts)
      message_data = ""

      raise "Recent blockhash not set" if @recent_blockhash.nil?

      decoded_blockhash = Base58.decode(@recent_blockhash)
      message_data << decoded_blockhash.to_s  # Directly append decoded bytes

      # Serialize the number of accounts (use 32-bit unsigned integer)
      message_data << [accounts.length].pack("N")

      accounts.each do |account|
        binding.pry
        raise "Invalid account size" unless account.bytesize == 32
        message_data << account
      end

      @instructions.each do |instruction|
        message_data << serialize_instruction(instruction, accounts)
      end

      message_data
    end

    def serialize_instruction(instruction, accounts)
      instruction_data = ""

      program_index = accounts.index(instruction.program_id)
      raise "Program ID not found in accounts" if program_index.nil?
      instruction_data << [program_index].pack("C")

      instruction_data << [instruction.keys.length].pack("C")

      instruction.keys.each do |key_meta|
        key_index = accounts.index(key_meta[:pubkey])
        raise "Account key #{key_meta[:pubkey]} not found in accounts" if key_index.nil?
        instruction_data << [key_index].pack("C")
      end

      # Use 32-bit unsigned integer for data length
      instruction_data << [instruction.data.length].pack("N")
      instruction_data << instruction.data

      instruction_data
    end
  end
end
