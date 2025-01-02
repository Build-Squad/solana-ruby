# frozen_string_literal: true

Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__dir__), 'lib/solana_ruby/**/*.rb')].each { |file| require file }

# SOL Transfer Testing Script

# Initialize the Solana client
client = SolanaRuby::HttpClient.new('http://127.0.0.1:8899')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

payer = SolanaRuby::Keypair.load_keypair('/Users/chinaputtaiahbellamkonda/.config/solana/id.json')
payer_pubkey = payer[:public_key]

# Generate a sender keypair and public key
owner = SolanaRuby::Keypair.generate
# owner = SolanaRuby::Keypair.from_private_key("2ce523e98cfd207a216a9ac4ef8b41c38c53a302af2022d2e89e1256d1b6a1d0")
owner_pubkey = owner[:public_key]
puts "owner public key: #{owner_pubkey}"
puts "payer private key: #{owner[:private_key]}"

# Airdrop some lamports to the sender's account
# lamports = 10 * 1_000_000_000
# sleep(1)
# result = client.request_airdrop(payer_pubkey, lamports)
# puts "Solana Balance #{lamports} lamports added sucessfully for the public key: #{payer_pubkey}"
# sleep(10)


mint_pubkey = "5xxFuuvLiB6Gz3vbaqgkjf8fvEDXowftFiL14qUSgPiM"
program_id = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
puts "payer public key: #{payer_pubkey}"

# associated_token_address = SolanaRuby::TransactionHelpers::TokenAccount.get_associated_token_address(mint_pubkey, payer_pubkey, program_id)

# puts "Associated Token Address: #{associated_token_address}"

transaction = SolanaRuby::TransactionHelper.create_associated_token_account(payer_pubkey, mint_pubkey, owner_pubkey, recent_blockhash)

resp = transaction.sign([payer])

puts "signature: #{resp}"

# Send the transaction
puts "Sending transaction..."
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"

