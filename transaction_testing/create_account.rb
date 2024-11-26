# frozen_string_literal: true

Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/**/*.rb')].each { |file| require file }

# Testing Script

client = SolanaRuby::HttpClient.new('http://127.0.0.1:8899')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Generate a sender keypair and public key
sender_keypair = SolanaRuby::Keypair.from_private_key("d22867a84ee1d91485a52c587793002dcaa7ce79a58bb605b3af2682099bb778")
sender_pubkey = sender_keypair[:public_key]
lamports = 1 * 1_000_000_000
space = 165
balance = client.get_balance(sender_pubkey)
puts "sender account balance: #{balance}, wait for few seconds to update the balance in solana when the balance 0"


# Generate a receiver keypair and public key
new_account = SolanaRuby::Keypair.generate
new_account_pubkey = new_account[:public_key]

# create a transaction instruction
transaction = SolanaRuby::TransactionHelper.create_and_sign_transaction(sender_pubkey, new_account_pubkey, lamports, space, recent_blockhash)

signed_transaction = transaction.sign([sender_keypair])
sleep(5)
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })
puts "Response: #{response}"
