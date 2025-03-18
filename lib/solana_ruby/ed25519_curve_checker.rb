module SolanaRuby
  class Ed25519CurveChecker
   require 'rbnacl'
   require 'openssl'

    # Constants for the Ed25519 curve
    Q = 2**255 - 19
    D = -121665 * OpenSSL::BN.new(121666).mod_inverse(Q).to_i % Q  # Ed25519 constant

    def self.on_curve?(public_key)
      return false unless public_key.bytesize == 32  # Must be exactly 32 bytes

      # Extract y-coordinate from the public key
      y = public_key.unpack1("H*").to_i(16) % Q

      # Compute x² from the Ed25519 curve equation: x² = (y² - 1) / (d * y² + 1) mod Q
      numerator   = (y**2 - 1) % Q
      denominator = (D * y**2 + 1) % Q

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
