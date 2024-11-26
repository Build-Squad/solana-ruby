# frozen_string_literal: true

Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/**/*.rb')].each { |file| require file }
# Dir["solana_ruby/*.rb"].each { |f| require_relative f.delete(".rb") }


# Testing Script

client = SolanaRuby::HttpClient.new('http://127.0.0.1:8899')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Generate a sender keypair and public key
fee_payer = SolanaRuby::Keypair.from_private_key("d22867a84ee1d91485a52c587793002dcaa7ce79a58bb605b3af2682099bb778")
fee_payer_pubkey = fee_payer[:public_key]
lamports = 10 * 1_000_000_000
space = 165

# get balance for the fee payer
balance = client.get_balance(fee_payer_pubkey)
puts "sender account balance: #{balance}, wait for few seconds to update the balance in solana when the balance 0"


# # Generate a receiver keypair and public key
keypair = SolanaRuby::Keypair.generate
receiver_pubkey = keypair[:public_key]
transfer_lamports = 1 * 1_000_000
# puts "Payer's full private key: #{sender_keypair[:full_private_key]}"
# # puts "Receiver's full private key: #{keypair[:full_private_key]}"
# # puts "Receiver's Public Key: #{keypair[:public_key]}"
mint_address = '9BvJGQC5FkLJzUC2TmYpi1iU8n9vt2388GLT5zvu8S1G'
token_program_id = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'

# Create a new transaction
transaction = SolanaRuby::TransactionHelper.new_spl_token_transaction(
  "9BvJGQC5FkLJzUC2TmYpi1iU8n9vt2388GLT5zvu8S1G",
  receiver_pubkey,
  fee_payer_pubkey,
  transfer_lamports,
  recent_blockhash
)
# # Get the sender's private key (ensure it's a string)
private_key = fee_payer[:private_key]
puts "Private key type: #{private_key.class}, Value: #{private_key.inspect}"

# Sign the transaction
signed_transaction = transaction.sign([fee_payer])

# Send the transaction to the Solana network
sleep(5)
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })
puts "Response: #{response}"

