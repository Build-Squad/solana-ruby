module SolanaRuby
  class Transaction
    require 'rbnacl'
    SIGNATURE_LENGTH = 64
    PACKET_DATA_SIZE = 1280 - 40 - 8
    DEFAULT_SIGNATURE = Array.new(64, 0)

    attr_accessor :instructions, :signatures, :fee_payer, :recent_blockhash, :message

    def initialize(recent_blockhash: nil, signatures: [], instructions: [], fee_payer: nil)
      @recent_blockhash = recent_blockhash
      @signatures = signatures
      @instructions = instructions
      @fee_payer = fee_payer
    end

    def add_instruction(instruction)
      @instructions << instruction
    end

    def set_fee_payer(pubkey)
      puts "Setting fee payer: #{pubkey.inspect}"  # Debugging output
      @fee_payer = pubkey  # Store as-is since Base58 gem can handle encoding/decoding
    end

    def set_recent_blockhash(blockhash)
      # raise "Invalid Base58 blockhash" unless Base58.valid?(blockhash)
      @recent_blockhash = blockhash  # Store as-is for similar reasons
    end

    def self.from(base64_string)
      bytes = Base64.decode64(base64_string).bytes
      signature_count = Utils.decode_length(bytes)
      signatures = signature_count.times.map do
        signature_bytes = bytes.slice!(0, SIGNATURE_LENGTH)
        Utils.bytes_to_base58(signature_bytes)
      end
      msg = Message.from(bytes)
      self.populate(msg, signatures)
    end

    def serialize
      sign_data = serialize_message

      signature_count = Utils.encode_length(signatures.length)
      raise 'invalid length!' if signatures.length > 256
      
      wire_transaction = signature_count

      signatures.each do |signature|
        if signature
          signature_bytes = signature[:signature]
          raise 'signature is empty' unless (signature_bytes)
          raise 'signature has invalid length' unless (signature_bytes.length == 64)
          wire_transaction += signature_bytes
          raise "Transaction too large: #{wire_transaction.length} > #{PACKET_DATA_SIZE}" unless wire_transaction.length <= PACKET_DATA_SIZE
          wire_transaction
        end
      end

      wire_transaction += sign_data
      wire_transaction
    end

    def to_base64
      Base64.strict_encode64(serialize.pack('C*'))
    end

    def add(item)
      instructions.push(item)
    end

    def sign(keys)
      raise 'No signers' unless keys.any?

      keys = keys.uniq{ |k| key[:public_key] }
      @signatures = keys.map do |key|
        {
          signature: nil,
          public_key: key[:public_key]
        }
      end

      message = compile_message
      partial_sign(message, keys)
      true
    end

    private

    def serialize_message
      compile.serialize
    end

    def compile
      message = compile_message
      signed_keys = message.account_keys.slice(0, message.header[:num_required_signatures])

      if signatures.length == signed_keys.length
        valid = signatures.each_with_index.all?{|pair, i| signed_keys[i] == pair[:public_key]}
        return message if valid
      end

      @signatures = signed_keys.map do |public_key|
        {
          signature: nil,
          public_key: public_key
        }
      end

      message
    end

    def compile_message
      check_for_errors
      fetch_message_data
      message = Message.new(
        header: {
          num_required_signatures: @num_required_signatures,
          num_readonly_signed_accounts: @num_readonly_signed_accounts,
          num_readonly_unsigned_accounts: @num_readonly_unsigned_accounts,
        },
        account_keys: @account_keys, recent_blockhash: recent_blockhash, instructions: @instructs
      )
     message
    end

    def check_for_errors
      raise 'Transaction recent_blockhash required' unless recent_blockhash

      puts 'No instructions provided' if instructions.length < 1

      if fee_payer.nil? && signatures.length > 0 && signatures[0][:public_key]
        @fee_payer = signatures[0][:public_key] if (signatures.length > 0 && signatures[0][:public_key])
      end
      
      raise('Transaction fee payer required') if @fee_payer.nil?

      instructions.each_with_index do |instruction, i|
        raise("Transaction instruction index #{i} has undefined program id") unless instruction.program_id
      end
    end

    def fetch_message_data
      program_ids = []
      account_metas= []

      instructions.each do |instruction|
        account_metas += instruction.keys
        program_ids.push(instruction.program_id) unless program_ids.include?(instruction.program_id)
      end

      # Append programID account metas
      append_program_id(program_ids, account_metas)

      # Sort. Prioritizing first by signer, then by writable
      signer_order(account_metas)

      # Cull duplicate account metas
      unique_metas = []
      add_unique_meta_data(unique_metas, account_metas)

      add_fee_payer_meta(unique_metas)

      # Disallow unknown signers
      disallow_signers(signatures, unique_metas)

      # Split out signing from non-signing keys and count header values
      signed_keys = []
      unsigned_keys = []
      header_params = split_keys(unique_metas, signed_keys, unsigned_keys)
      @account_keys = signed_keys + unsigned_keys
      
      # add instruction structure
      @instructs = add_instructs
    end

    def append_program_id(program_ids, account_metas)
      program_ids.each do |programId|
        account_metas.push({
                            pubkey: programId,
                            is_signer: false,
                            is_writable: false,
                          })
      end
    end

    def signer_order(account_metas)
      account_metas.sort! do |x, y|
        check_signer = x[:is_signer] == y[:is_signer] ? nil : x[:is_signer] ? -1 : 1
        check_writable = x[:is_writable] == y[:is_writable] ? nil : (x[:is_writable] ? -1 : 1)
        (check_signer || check_writable) || 0
      end
    end

    def add_unique_meta_data(unique_metas, account_metas)
      account_metas.each do |account_meta|
        pubkey_string = account_meta[:pubkey]
        unique_index = unique_metas.find_index{|x| x[:pubkey] == pubkey_string }
        if unique_index
          unique_metas[unique_index][:is_writable] = unique_metas[unique_index][:is_writable] || account_meta[:is_writable]
        else
          unique_metas.push(account_meta);
        end
      end
    end

    def add_fee_payer_meta(unique_metas)
      # Move fee payer to the front
      fee_payer_index = unique_metas.find_index { |x| x[:pubkey] == fee_payer }
      if fee_payer_index
        payer_meta = unique_metas.delete_at(fee_payer_index)
        payer_meta[:is_signer] = true
        payer_meta[:is_writable] = true
        unique_metas.unshift(payer_meta)
      else
        unique_metas.unshift({
                              pubkey: fee_payer,
                              is_signer: true,
                              is_writable: true,
                            })
      end
    end

    def disallow_signers(signatures, unique_metas)
      signatures.each do |signature|
        unique_index = unique_metas.find_index{ |x| x[:pubkey] == signature[:public_key] }

        if unique_index
          unique_metas[unique_index][:is_signer] = true unless unique_metas[unique_index][:is_signer]
        else
          raise "unknown signer: #{signature[:public_key]}"
        end
      end
    end

    def add_instructs
      instructions.map do |instruction|
        {
          program_id_index: @account_keys.index(instruction.program_id),
          accounts: instruction.keys.map { |meta| @account_keys.index(meta[:pubkey]) },
          data: instruction.data
        }
      end
    end

    def split_keys(unique_metas, signed_keys, unsigned_keys)
      @num_required_signatures = 0
      @num_readonly_signed_accounts = 0
      @num_readonly_unsigned_accounts = 0
      unique_metas.each do |meta|
        if meta[:is_signer]
          signed_keys.push(meta[:pubkey])
          @num_required_signatures += 1
          @num_readonly_signed_accounts += 1 if (!meta[:is_writable])
        else
          unsigned_keys.push(meta[:pubkey])
          @num_readonly_unsigned_accounts += 1 if (!meta[:is_writable])
        end
      end
    end

    def partial_sign(message, keys)
      sign_data = message.serialize
      keys.each do |key|
        private_key_bytes = [key[:private_key]].pack('H*')
        signing_key = RbNaCl::Signatures::Ed25519::SigningKey.new(private_key_bytes)
        signature = signing_key.sign(sign_data.pack('C*')).bytes
        add_signature(key[:public_key], signature)
      end
    end

    def add_signature(pubkey,  signature)
      raise 'error' unless signature.length === 64
      index = signatures.find_index{|s| s[:public_key] == pubkey}
      raise "unknown signer: #{pubkey}" unless index

      @signatures[index][:signature] = signature
    end
  end
end
