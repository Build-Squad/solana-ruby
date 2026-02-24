## [Unreleased]

## 2.1.6 – 2026-02-24

### Fixed

- Fixed Ed25519 public key curve validation:
  - Clear x-sign bit correctly
  - Interpret y-coordinate as little-endian
- Fixed PDA / ATA derivation mismatches caused by incorrect seed hashing
- Resolves invalid Associated Token Address generation (issue #13)

This release fixes cases where previously generated ATAs could differ
from on-chain derivation and fail with:
"Provided seeds do not result in a valid address"

## [0.1.0] - 2024-07-31

- Initial release
