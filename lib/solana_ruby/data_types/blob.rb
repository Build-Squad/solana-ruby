module SolanaRuby
  module DataTypes
    class Blob
      attr_reader :size

      # Constructor to initialize size of the blob
      def initialize(size)
        raise ArgumentError, "Size must be a positive integer" unless size.is_a?(Integer) && size > 0
        @size = size
      end

      # Serialize the given object to a byte array
      def serialize(obj)
        # Ensure obj is an array and then convert to byte array
        obj = [obj] unless obj.is_a?(Array)
        raise ArgumentError, "Object must be an array of bytes" unless obj.all? { |e| e.is_a?(Integer) && e.between?(0, 255) }

        obj.pack('C*').bytes
      end

      # Deserialize a byte array into the original object format
      def deserialize(bytes)
        # Ensure the byte array is of the correct size
        raise ArgumentError, "Byte array size must match the expected size" unless bytes.length == @size

        bytes.pack('C*')
      end
    end
  end
end
