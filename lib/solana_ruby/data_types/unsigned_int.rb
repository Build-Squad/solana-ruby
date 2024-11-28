module SolanaRuby
  module DataTypes
    class UnsignedInt
      attr_reader :size

      BITS = {
        8 => { directive: 'C', size: 1 },   # 8-bit unsigned integer
        32 => { directive: 'L<', size: 4 }, # 32-bit little-endian unsigned integer
        64 => { directive: 'Q<', size: 8 }  # 64-bit little-endian unsigned integer
      }

      def initialize(bits)
        @bits = bits
        type = BITS[@bits]
        raise "Unsupported size. Supported sizes: #{BITS.keys.join(', ')} bits" unless type
        @size = type[:size]
        @directive = type[:directive]
      end

      # Serialize the unsigned integer into properly aligned bytes
      def serialize(obj)
        raise "Can only serialize integers" unless obj.is_a?(Integer)
        raise "Cannot serialize negative integers" if obj.negative?

        if obj >= 256**@size
          raise "Integer too large to fit in #{@size} bytes"
        end

        [obj].pack(@directive).bytes
      end

      # Deserialize bytes into the unsigned integer
      def deserialize(bytes)
        raise "Invalid serialization (expected #{@size} bytes, got #{bytes.size})" if bytes.size != @size

        bytes.pack('C*').unpack(@directive).first
      end
    end
  end
end
