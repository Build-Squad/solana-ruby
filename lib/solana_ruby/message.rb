module SolanaRuby
  class Message
    PUBKEY_LENGTH = 32

    attr_reader :header, :account_keys, :recent_blockhash, :instructions

    def initialize(header:, account_keys:, recent_blockhash:, instructions:)
      @header = header
      @account_keys = account_keys
      @recent_blockhash = recent_blockhash
      @instructions = instructions
    end

    def self.from(bytes)
      bytes = bytes.dup
      num_required_signatures = bytes.shift
      num_readonly_signed_accounts = bytes.shift
      num_readonly_unsigned_accounts = bytes.shift
      account_count = Utils.decode_length(bytes)

      account_keys = account_count.times.map do
        account_bytes = bytes.slice!(0, PUBKEY_LENGTH)
        Utils.bytes_to_base58(account_bytes)
      end

      recent_blockhash_bytes = bytes.slice!(0, PUBKEY_LENGTH)
      recent_blockhash = Utils.bytes_to_base58(recent_blockhash_bytes)

      instruction_count = Utils.decode_length(bytes)
      instructions = instruction_count.times.map do
        program_id_index = bytes.shift
        account_count = Utils.decode_length(bytes)

        accounts = bytes.slice!(0, account_count)

        data_length = Utils.decode_length(bytes)
        data_bytes = bytes.slice!(0, data_length)
        {program_id_index: program_id_index, accounts: accounts, data: data_bytes}
      end
      self.new({
        header: {
          num_required_signatures: num_required_signatures,
          num_readonly_signed_accounts:num_readonly_signed_accounts,
          num_readonly_unsigned_accounts:num_readonly_unsigned_accounts,
        },
        account_keys: account_keys,
        recent_blockhash: recent_blockhash,
        instructions: instructions
      })
    end

    def serialize
      num_keys = account_keys.length
      key_count = Utils.encode_length(num_keys)

      layout = SolanaRuby::DataTypes::Layout.new({
        num_required_signatures: :blob1,
        num_readonly_signed_accounts: :blob1,
        num_readonly_unsigned_accounts: :blob1,
        key_count: SolanaRuby::DataTypes::Blob.new(key_count.length),
        keys: SolanaRuby::DataTypes::Sequence.new(num_keys, SolanaRuby::DataTypes::Blob.new(32)),
        recent_blockhash: SolanaRuby::DataTypes::Blob.new(32)
      })

      sign_data = layout.serialize({
        num_required_signatures: header[:num_required_signatures],
        num_readonly_signed_accounts: header[:num_readonly_signed_accounts],
        num_readonly_unsigned_accounts: header[:num_readonly_unsigned_accounts],
        key_count: key_count,
        keys: account_keys.map{|x| Utils.base58_to_bytes(x)},
        recent_blockhash: Utils.base58_to_bytes(recent_blockhash)
      })

      instruction_count = Utils.encode_length(@instructions.length)
      sign_data += instruction_count

      data = @instructions.map do |instruction|
        instruction_layout = SolanaRuby::DataTypes::Layout.new({
          program_id_index: :uint8,
          key_indices_count: SolanaRuby::DataTypes::Blob.new(key_count.length),
          key_indices: SolanaRuby::DataTypes::Sequence.new(num_keys, SolanaRuby::DataTypes::Blob.new(8)),
          data_length: SolanaRuby::DataTypes::Blob.new(key_count.length),
          data: SolanaRuby::DataTypes::Sequence.new(num_keys, SolanaRuby::DataTypes::UnsignedInt.new(8)),
        })

        key_indices_count = Utils.encode_length(instruction[:accounts].length)
        data_count = Utils.encode_length(instruction[:data].length)

        instruction_layout.serialize({
          program_id_index: instruction[:program_id_index],
          key_indices_count: key_indices_count,
          key_indices: instruction[:accounts],
          data_length: data_count,
          data: instruction[:data]
        })
      end.flatten

      sign_data += data
      sign_data
    end

    def is_account_writable(index)
      index < header[:num_required_signatures] - header[:num_readonly_signed_accounts] ||
      (index >= header[:num_required_signatures] && index <  account_keys.length - header[:num_readonly_unsigned_accounts])
    end
  end
end
