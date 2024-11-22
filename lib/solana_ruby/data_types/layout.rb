module SolanaRuby
  module DataTypes
    class Layout
      attr_reader :fields

      def initialize(fields)
        @fields = fields
      end

      def serialize(params)
        fields.map do |field, type|
          data_type = if type.is_a?(Symbol)
                   SolanaRuby::DataTypes.send(type)
                 else
                   type
                 end

          data_type.serialize(params[field])
        end.flatten
      end

      def deserialize(bytes)
        result = {}
        fields.map do |field, type|
          data_type = if type.is_a?(Symbol)
                   SolanaRuby::DataTypes.send(type)
                 else
                   type
                 end
          result[field] = data_type.deserialize(bytes.shift(data_type.size))
        end
        result
      end
    end
  end
end