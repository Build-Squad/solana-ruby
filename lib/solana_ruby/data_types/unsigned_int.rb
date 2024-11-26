module SolanaRuby
  module DataTypes
    class UnsignedInt
      attr_reader :size

      BITS = {
        8 => { directive: 'C*', size: 1 },
        32 => { directive: 'L*', size: 4 },
        64 => { directive: 'Q*', size: 8 }
      }

      def initialize(bits)
        @bits = bits
        type = BITS[@bits]
        raise "Can only fit #{BITS.keys}" unless type
        @size = type[:size]
        @directive = type[:directive]
      end

      # Serialize the unsigned integer into bytes
      def serialize(obj)
        raise "Can only serialize integers" unless obj.is_a?(Integer)
        raise "Cannot serialize negative integers" if obj < 0

        if obj >= 256**@size
          raise "Integer too large (does not fit in #{@size} bytes)"
        end

        [obj].pack(@directive).bytes
      end

      # Deserialize bytes into the unsigned integer
      def deserialize(bytes)
        raise "Invalid serialization (wrong size)" if bytes.size != @size

        bytes.pack('C*').unpack(@directive).first
      end
    end
  end
end
