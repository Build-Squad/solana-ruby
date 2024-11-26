module SolanaRuby
  module DataTypes
    class Sequence
      def initialize count, type
        @count = count
        @type = type
      end

      def serialize items
        items.map do |item|
          @type.serialize(item)
        end.flatten
      end

      def deserialize bytes
        @count.times.map do
          current_bytes = bytes.shift(@type.size)
          @type.deserialize(current_bytes)
        end
      end
    end
  end
end
