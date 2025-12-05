module SolanaRuby
  class Ed25519CurveChecker
   require 'rbnacl'
   require 'openssl'

    # Constants for the Ed25519 curve
    Q = 2**255 - 19
    D = -121665 * OpenSSL::BN.new(121666).mod_inverse(Q).to_i % Q  # Ed25519 constant

    def self.on_curve?(public_key)
      return false unless public_key.bytesize == 32  # Must be exactly 32 bytes

      # Extract bytes - needed for bitwise operations
      y_bytes = public_key.bytes
      # Ed25519 Curve does not use the x sign bit, y value is (0-254) so we need to clear the bit 255 (x sign bit)
      # Byte 31, bit 7 is the sign bit
      y_bytes[31] &= 0x7F # binary 01111111

      # shift left bytes by 8 bits to get little-endian order then sum to get integer
      # In little-endian: byte[0] is 2^0, byte[1] is 2^8, ..., byte[31] is 2^248
      y = y_bytes.each_with_index.sum { |byte, index| byte << (8 * index) }

      # Reduce modulo Q (field arithmetic) to ensure it's within the valid range
        y = y % Q

      # Compute x² from the Ed25519 curve equation: x² = (y² - 1) / (d * y² + 1) mod Q
      y_squared = y**2
      numerator   = (y_squared - 1) % Q
      denominator = (D * y_squared + 1) % Q

      # Compute the modular inverse of the denominator
      denominator_inv = OpenSSL::BN.new(denominator).mod_inverse(Q).to_i rescue nil
      return false if denominator_inv.nil?  # If inverse doesn't exist, it's off-curve

      x_squared = (numerator * denominator_inv) % Q

      # Check if x² is a quadratic residue (i.e., has a valid square root mod Q)
      legendre_symbol = OpenSSL::BN.new(x_squared).mod_exp((Q - 1) / 2, Q).to_i

      # If legendre symbol is 1, it has a square root, meaning it's ON the curve
      legendre_symbol == 1
    rescue StandardError => e
      puts "Curve check error: #{e.message}"
      false
    end
  end
end
