module SolanaRuby
  module DataTypes
    extend self

    def uint8
      UnsignedInt.new(8)
    end

    def uint32
      UnsignedInt.new(32)
    end

    def uint64
      UnsignedInt.new(64)
    end

    def near_int64
      NearInt64.new
    end

    def blob1
      Blob.new(1)
    end
  end
end
