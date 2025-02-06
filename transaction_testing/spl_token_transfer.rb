# frozen_string_literal: true

Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/**/*.rb')].each { |file| require file }
# Dir["solana_ruby/*.rb"].each { |f| require_relative f.delete(".rb") }


# Testing Script

client = SolanaRuby::HttpClient.new('http://127.0.0.1:8899')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Generate a sender keypair and public key
fee_payer = SolanaRuby::Keypair.from_private_key('e06f61b73aa625690ef97ed3704e8dc22bc835092e94cc9ae5650b516f26c91a')
fee_payer_pubkey = fee_payer[:public_key]
lamports = 10 * 1_000_000_000
space = 165

# get balance for the fee payer
balance = client.get_balance(fee_payer_pubkey)
puts "sender account balance: #{balance}, wait for few seconds to update the balance in solana when the balance 0"


# # Generate a receiver keypair and public key
keypair = SolanaRuby::Keypair.from_private_key('f7173083807e1692e844aa2ec515eca18d016fc5e4468be75be20f6093de6641')
receiver_pubkey = keypair[:public_key]
transfer_lamports = 1_000_000
mint_address = 'GDAWgGT42CqgaMds81JFVoqyJ4WBvfQsHAshPggAfXCM'

senders_token_account = SolanaRuby::TransactionHelpers::TokenAccount.get_associated_token_address(mint_address, fee_payer_pubkey)
receivers_token_account = SolanaRuby::TransactionHelpers::TokenAccount.get_associated_token_address(mint_address, receiver_pubkey)
puts "senders_token_account: #{senders_token_account}"
puts "receivers_token_account: #{receivers_token_account}"

# Create a new transaction
transaction = SolanaRuby::TransactionHelper.new_spl_token_transaction(
  senders_token_account,
  mint_address,
  receivers_token_account,
  fee_payer_pubkey,
  transfer_lamports,
  9,
  recent_blockhash,
  []
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

