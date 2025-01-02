require 'base58'
require 'openssl'

module SolanaRuby
  class PublicKey
    PUBLIC_KEY_LENGTH = 32

    attr_reader :bn

    def initialize(value)
      case value
      when PublicKey
        @bn = value.bn
      when String
        decoded = decode_base58(value)
        validate_length(decoded)
        @bn = to_bn(decoded)
      when Array
        binary = value.pack('C*')
        validate_length(binary)
        @bn = to_bn(binary)
      else
        raise ArgumentError, "Unsupported input type: #{value.class}"
      end
    end

    # Converts the public key to Base58
    def to_base58
      Base58.binary_to_base58(to_bytes, :bitcoin)
    end

    # Converts the public key to a binary string
    def to_bytes
      padded_bn = @bn.to_s(2) # Binary string from BigNum
      if padded_bn.bytesize < PUBLIC_KEY_LENGTH
        "\x00" * (PUBLIC_KEY_LENGTH - padded_bn.bytesize) + padded_bn
      elsif padded_bn.bytesize > PUBLIC_KEY_LENGTH
        raise "PublicKey byte length exceeds #{PUBLIC_KEY_LENGTH} bytes"
      else
        padded_bn
      end
    end

    private

    def decode_base58(value)
      Base58.base58_to_binary(value, :bitcoin)
    rescue ArgumentError => e
      raise ArgumentError, "Invalid Base58 encoding: #{e.message}"
    end

    def validate_length(data)
      unless data.bytesize == PUBLIC_KEY_LENGTH
        raise ArgumentError, "Invalid public key length: expected #{PUBLIC_KEY_LENGTH} bytes, got #{data.bytesize}"
      end
    end

    def to_bn(input)
      OpenSSL::BN.new(input, 2)
    end
  end
end
