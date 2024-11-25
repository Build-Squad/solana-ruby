Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/**/*.rb')].each { |file| require file }
require 'pry'
# Testing Script

client = SolanaRuby::HttpClient.new('http://127.0.0.1:8899')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Generate a sender keypair and public key
sender_keypair = SolanaRuby::Keypair.generate
sender_pubkey = sender_keypair[:public_key]
lamports = 10 * 1_000_000_000

# Airdrop some lamports to the sender's account
sleep(1)
result = client.request_airdrop(sender_pubkey, lamports)
puts "Solana Balance #{lamports} lamports added sucessfully for the public key: #{sender_pubkey}"
sleep(10)
puts "sender account balance: #{client.get_balance(sender_pubkey)}, wait for few seconds to update the balance in solana when the balance shows 0"


# Generate a receiver keypair and public key
keypair = SolanaRuby::Keypair.generate
receiver_pubkey = keypair[:public_key]
transfer_lamports = 1 * 1_000_000
puts "Payer's full private key: #{sender_keypair[:full_private_key]}"
puts "Receiver's full private key: #{keypair[:full_private_key]}"
puts "Receiver's Public Key: #{keypair[:public_key]}"

# Create a new transaction
transaction = SolanaRuby::TransactionHelper.new_sol_transaction(
  sender_pubkey,
  receiver_pubkey,
  transfer_lamports,
  recent_blockhash
)

# Get the sender's private key (ensure it's a string)
private_key = sender_keypair[:private_key]
puts "Private key type: #{private_key.class}, Value: #{private_key.inspect}"

# Sign the transaction
signed_transaction = transaction.sign([sender_keypair])

# Send the transaction to the Solana network
sleep(5)
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })
puts "Response: #{response}"

