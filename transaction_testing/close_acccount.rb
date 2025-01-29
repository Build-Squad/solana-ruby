# frozen_string_literal: true
require 'pry'

Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/**/*.rb')].each { |file| require file }

# SOL Transfer Testing Script

# Initialize the Solana client
client = SolanaRuby::HttpClient.new('http://127.0.0.1:8899')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Assuming you already have the following public keys
payer = SolanaRuby::Keypair.load_keypair('/Users/chinaputtaiahbellamkonda/.config/solana/id.json')
payer_pubkey = payer[:public_key]
owner = 'BuqVvwzGAwjZ2mVsxCDpPaqBeJCZxoMWaK6k9pKznkyE'
account_to_close_pubkey = 'Pu6PzvBXkqH4reyuRuNu7YG8JWvSBa2uNsUNT5MSpHJ'
destination_pubkey = '6Twj5dcX89eQoqZTeTHhqzRfXcrX5ZkrJMDh3NgzbRJD'

# Create the transaction to close the account
transaction = SolanaRuby::TransactionHelper.close_account(
  payer_pubkey, 
  account_to_close_pubkey, 
  destination_pubkey,
  owner,
  recent_blockhash
)

resp = transaction.sign([payer])

puts "signature: #{resp}"

# Send the transaction
puts "Sending transaction..."
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"

