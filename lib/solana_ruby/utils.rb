require 'base58'
require 'digest/sha2'

module SolanaRuby
  class Utils
    class << self
      # Decodes a length-prefixed byte array using a variable-length encoding.
      def decode_length(bytes)
        raise ArgumentError, "Input must be an array of bytes" unless bytes.is_a?(Array)

        length = 0
        size = 0
        loop do
          raise "Unexpected end of bytes during length decoding" if bytes.empty?

          byte = bytes.shift
          length |= (byte & 0x7F) << (size * 7)
          size += 1
          break if (byte & 0x80).zero?
        end
        length
      end

      # Encodes a length as a variable-length byte array.
      def encode_length(length)
        raise ArgumentError, "Length must be a non-negative integer" unless length.is_a?(Integer) && length >= 0

        bytes = []
        loop do
          byte = length & 0x7F
          length >>= 7
          if length.zero?
            bytes << byte
            break
          else
            bytes << (byte | 0x80)
          end
        end
        bytes
      end

      # Converts a byte array to a Base58-encoded string.
      def bytes_to_base58(bytes)
        raise ArgumentError, "Input must be an array of bytes" unless bytes.is_a?(Array)
        
        Base58.binary_to_base58(bytes.pack('C*'), :bitcoin)
      end

      # Converts a Base58-encoded string to a byte array.
      def base58_to_bytes(base58_string)
        raise ArgumentError, "Input must be a non-empty string" unless base58_string.is_a?(String) && !base58_string.empty?

        Base58.base58_to_binary(base58_string, :bitcoin).bytes
      rescue ArgumentError
        raise "Invalid Base58 string: #{base58_string}"
      end

      # Computes the SHA-256 hash of the given data and returns it as a hexadecimal string.
      def sha256(data)
        raise ArgumentError, "Data must be a string" unless data.is_a?(String)

        Digest::SHA256.hexdigest(data)
      end
    end
  end
end
