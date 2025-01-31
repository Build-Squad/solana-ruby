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
payer = SolanaRuby::Keypair.from_private_key('7bcd98e0be17a23f5adbb199d614f5df28e2491ca9856a7efc276245d9d22f26')
payer_pubkey = payer[:public_key]
owner = SolanaRuby::Keypair.from_private_key('7bcd98e0be17a23f5adbb199d614f5df28e2491ca9856a7efc276245d9d22f26')
account_to_close_pubkey = 'bnKvAbZzNjF123Wa9g4yQNva5adLqj2fLNfipZ2KgP6' # associated token account closing address 
destination_pubkey = 'DCm6PCsdRoEXzHUdHxXnJTP65gYSPK5p8h9Cui3quiQQ' # associated token account receiving address

# Create the transaction to close the account
transaction = SolanaRuby::TransactionHelper.close_account(
  account_to_close_pubkey, 
  destination_pubkey,
  owner[:public_key],
  payer_pubkey,
  [],
  recent_blockhash
)

resp = transaction.sign([payer, owner])

puts "signature: #{resp}"

# Send the transaction
puts "Sending transaction..."
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"

