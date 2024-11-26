module SolanaRuby
  module DataTypes
    class Layout
      attr_reader :fields

      def initialize(fields)
        @fields = fields
      end

      def serialize(params)
        fields.flat_map do |field, type|
          data_type = type.is_a?(Symbol) ? SolanaRuby::DataTypes.send(type) : type
          data_type.serialize(params[field])
        end
      end

      def deserialize(bytes)
        result = {}
        fields.map do |field, type|
          data_type = type.is_a?(Symbol) ? SolanaRuby::DataTypes.send(type) : type
          result[field] = data_type.deserialize(bytes.shift(data_type.size))
        end
        result
      end
    end
  end
end
