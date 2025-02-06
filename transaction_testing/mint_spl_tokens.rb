# frozen_string_literal: true

Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/**/*.rb')].each { |file| require file }

# SOL Transfer Testing Script

# Initialize the Solana client
client = SolanaRuby::HttpClient.new('http://127.0.0.1:8899')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Example parameters
mint_account = "2DoNkK31X9HH5MXY6pBeb3RDZ1ZDK7wgXrcvnyipXNvf"
destination_account = "DCm6PCsdRoEXzHUdHxXnJTP65gYSPK5p8h9Cui3quiQQ"
mint_authority = SolanaRuby::Keypair.load_keypair('/Users/chinaputtaiahbellamkonda/.config/solana/id.json')
puts "Full private key: #{mint_authority[:full_private_key]}"
puts "Private key: #{mint_authority[:private_key]}"
puts "Public key: #{mint_authority[:public_key]}"
amount = 1_000_000_00_00 # Amount to mint in smallest units
multi_signers = [] # If multi-signature is used, include public keys here

# Create a mint transaction
transaction = SolanaRuby::TransactionHelper.mint_spl_tokens(
  mint_account,
  destination_account,
  mint_authority[:public_key],
  amount,
  recent_blockhash,
  multi_signers
)

resp = transaction.sign([mint_authority])

puts "signature: #{resp}"

# Send the transaction
puts "Sending transaction..."
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"
