# frozen_string_literal: true

Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/**/*.rb')].each { |file| require file }

# Initialize Solana client
client = SolanaRuby::HttpClient.new('http://127.0.0.1:8899')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]
puts "Recent Blockhash: #{recent_blockhash}"

# Sender keypair and public key
private_key = "d22867a84ee1d91485a52c587793002dcaa7ce79a58bb605b3af2682099bb778"
sender_keypair = SolanaRuby::Keypair.from_private_key(private_key)
sender_pubkey = sender_keypair[:public_key]
puts "Sender Public Key: #{sender_pubkey}"

# Check sender's account balance
balance = client.get_balance(sender_pubkey)
puts "Sender account balance: #{balance} lamports"
if balance == 0
  puts "Balance is zero, waiting for balance update..."
  sleep(10)
end

# new keypair and public key (new account)
new_account = SolanaRuby::Keypair.generate
new_account_pubkey = new_account[:public_key]
puts "New Account Public Key: #{new_account_pubkey}"

# Parameters for account creation
lamports = 1 * 1_000_000_000 # Lamports to transfer
space = 165 # Space allocation (bytes)
program_id = SolanaRuby::TransactionHelper::SYSTEM_PROGRAM_ID

# Create and sign the transaction
transaction = SolanaRuby::TransactionHelper.create_account(
  sender_pubkey,
  new_account_pubkey,
  lamports,
  space,
  recent_blockhash,
  program_id
)

# Sign transaction with both sender and new account keypairs
transaction.sign([sender_keypair, new_account])

# Send the transaction
puts "Sending transaction..."
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"
puts "New account created successfully with Public Key: #{new_account_pubkey}"

