module SolanaRuby
  class Ed25519CurveChecker
    # Constants for Ed25519
    P = 2**255 - 19
    ONE = 1

    # Main function to check if a public key is on the Ed25519 curve
    def self.on_curve?(public_key_bytes)
      # Validate public key length
      return false unless public_key_bytes.bytesize == 32 # Public key must be 32 bytes

      begin
        # Decode the y-coordinate from the public key
        y = decode_y(public_key_bytes)

        # Validate if y is a quadratic residue on the curve equation
        y_squared = (y * y) % P
        numerator = (y_squared - 1) % P
        denominator = (D * y_squared + 1) % P

        # Ensure denominator isn't zero to avoid invalid computation
        return false if denominator.zero?

        # Calculate x_squared = numerator * modular_inverse(denominator, P) mod P
        x_squared = (numerator * modular_inverse(denominator, P)) % P

        # Check if x_squared is a valid quadratic residue
        quadratic_residue?(x_squared)
      rescue StandardError => e
        puts "Error during curve check: #{e.message}"
        false
      end
    end

    private

    # Decode the y-coordinate from the public key
    def self.decode_y(public_key_bytes)
      # Converts byte array directly to integer and maps it onto the curve's modulus
      public_key_bytes.unpack1('H*').to_i(16) % P
    end

    # Determine if value is a quadratic residue modulo P
    def self.quadratic_residue?(value)
      # Quadratic residues satisfy value^((p - 1) / 2) mod P == 1
      value.pow((P - 1) / 2, P) == 1
    end

    # Modular inverse using the Extended Euclidean Algorithm
    def self.modular_inverse(value, mod_value)
      t, new_t = 0, 1
      r, new_r = mod_value, value

      while new_r != 0
        quotient = r / new_r
        t, new_t = new_t, t - quotient * new_t
        r, new_r = new_r, r - quotient * new_r
      end

      raise ArgumentError, 'Value has no modular inverse' if r > 1

      t += mod_value if t.negative?
      t % mod_value
    end
  end

  # Calculate the Ed25519 constant D
  # D = -121665 * modular_inverse(121666, P) mod P
  D = (-121665 * Ed25519CurveChecker.modular_inverse(121666, Ed25519CurveChecker::P)) % Ed25519CurveChecker::P
end
