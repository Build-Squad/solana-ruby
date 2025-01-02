# frozen_string_literal: true

Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/**/*.rb')].each { |file| require file }

# SOL Transfer Testing Script

# Initialize the Solana client
client = SolanaRuby::HttpClient.new('http://127.0.0.1:8899')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Example parameters
mint_account = "5FQhi6Kq3CKDaB3bus21ZqcL7wyeZNR18otFGoDfrZXU"
destination_account = "C2wY5TKnj52S4s9yRUTNqitRe5gmFokSCoppJS6t63aa"
mint_authority = SolanaRuby::Keypair.load_keypair('/Users/chinaputtaiahbellamkonda/.config/solana/id.json')
amount = 1_000_000 # Amount to mint in smallest units
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
