# SolanaRuby

`SolanaRuby` is a lightweight Ruby client for interacting with the Solana blockchain through its JSON-RPC API. It allows developers to perform various queries on the Solana network such as fetching solana balance, acccount information, and more.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'solana-ruby-web3js'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install solana-ruby-web3js

## Usage

To start using the Solana RPC client, initialize it with or without the RPC URL. The default URL points to the Solana Mainnet. If you wish to connect to another network like Devnet or Testnet, you can specify the URL.

```ruby
require 'solana_ruby'

# Initialize the client (defaults to Mainnet(https://api.mainnet-beta.solana.com))
client = SolanaRuby::HttpClient.new()

# Optionally, provide a custom RPC URL
# client = SolanaRuby::HttpClient.new("https://api.devnet.solana.com")
```

### Fetch Solana Account Balance

Once the client is initialized, you can make API calls to the Solana network. For example, to get the solana balance of a given account:

```ruby
# Replace 'pubkey' with the actual public key of the solana account

pubkey = 'Fg6PaFpoGXkYsidMpWxTWqSKJf6KJkUxX92cnv7WMd2J'

result = client.get_balance(pubkey)

puts result
```

### Fetch Parsed Account Info

```ruby
# Replace 'pubkey' with the actual public key of the account
pubkey = 'Fg6PaFpoGXkYsidMpWxTWqSKJf6KJkUxX92cnv7WMd2J'

# Example of options that can be passed:
options = {
  commitment: 'finalized',   # Specifies the level of commitment for querying state (e.g., 'finalized', 'confirmed', 'processed')
  encoding: 'jsonParsed'     # Specifies the encoding format (e.g., 'jsonParsed', 'base64', etc.)
}

result = client.get_parsed_account_info(pubkey, options)

puts result
```

### More Information on Solana Methods

For a more detailed overview of Solana's available RPC methods, visit the official documentation:

- [Solana HTTP RPC Methods](https://solana.com/docs/rpc/http)
- [Solana WebSocket RPC Methods](https://solana.com/docs/rpc/websocket)
- [Solana web3.js Connection Methods](https://solana-labs.github.io/solana-web3.js/classes/Connection.html)

### Options Parameter

The options parameter is a hash that can include the following fields and more, allowing for customized responses:

- **commitment**: Specifies the level of commitment desired when querying state. Options include:

  - 'finalized': Query the most recent block confirmed by supermajority of the cluster.
  - 'confirmed': Query the most recent block that has been voted on by supermajority of the cluster.
  - 'processed': Query the most recent block regardless of cluster voting.

- **encoding**: Defines the format of the returned account data. Possible values include:

  - 'jsonParsed': Returns data in a JSON-parsed format.
  - 'base64': Returns raw account data in Base64 encoding.
  - 'base64+zstd': Returns compressed Base64 data.

- **epoch**: Specify the epoch when querying for certain information like epoch details.

- **skipPreflight**: If true, skip the preflight transaction verification. Preflight ensures that a transaction is valid before sending it to the network, but skipping this can result in faster submission.

- **maxRetries**: Specify how many times to retry sending a transaction before giving up.

- **recentBlockhash**: Provide a custom recent blockhash for a transaction if not relying on the default.

By providing options, you can control the nature of the returned data and the reliability of the query.

### Filters Parameter

The filters parameter allows you to specify conditions when querying accounts and other resources. Here are some common filters:

#### Token Accounts by Owner

```ruby
# Replace 'owner_pubkey' with the owner's public key
owner_pubkey = 'Fg6PaFpoGXkYsidMpWxTWqSKJf6KJkUxX92cnv7WMd2J'

# Query for token accounts owned by this public key
filters = [{ mint: 'TokenMintPublicKey' }]

result = client.get_token_accounts_by_owner(owner_pubkey, filters)

puts result
```

#### Account Filters

You can use the filters parameter to apply conditions for certain queries, such as fetching token accounts by a specific owner or a specific token program. Below are examples of filters that can be used in different queries.

#### Mint Filter

- Filter accounts by a specific token mint.

```ruby
filters = [{ mint: 'TokenMintPublicKey' }]

result = client.get_token_accounts_by_owner(owner_pubkey, filters)
```

#### Program Filter

- Filter accounts associated with a particular program, such as the token program.

```ruby
filters = [{ programId: 'TokenProgramPublicKey' }]

result = client.get_token_accounts_by_owner(owner_pubkey, filters)
```

#### Data Size Filter

- Filter accounts by the exact size of the account data.

```ruby
filters = [{ dataSize: 165 }]

result = client.get_program_accounts('ProgramPublicKey', filters)
```

#### Memcmp Filter

- Filter by matching a specific slice of bytes at a given offset in account data.

```ruby
filters = [{
  memcmp: {
    offset: 0,
    bytes: 'Base58EncodedBytes'
  }
}]

result = client.get_program_accounts('ProgramPublicKey', filters)
```

## WebSocket Methods

The SolanaRuby gem also provides WebSocket methods to handle real-time notifications and updates from the Solana blockchain. To use the WebSocket client:

```ruby
# Initialize the WebSocket client
ws_client = SolanaRuby::WebSocketClient.new("wss://api.mainnet-beta.solana.com")

# Subscribe to slot change notifications
subscription_id = ws_client.on_slot_change do |slot_info|
  puts "Slot changed: #{slot_info}"
end

# Sleep to hold the process and show updates
sleep 60 # Adjust the duration as needed to view updates

# Unsubscribe from slot change notifications
ws_client.remove_slot_change_listener(subscription_id)
puts "Unsubscribed from slot change notifications."
```

The following methods are supported by the WebSocketClient:

- **Account Change**: Subscribe to changes in an account's state.

  `ws_client.on_account_change(pubkey) { |account_info| puts account_info }`

- **Program Account Change**: Subscribe to changes in accounts owned by a specific program.

  `ws_client.on_program_account_change(program_id, filters) { |program_account_info| puts program_account_info }`

- **Logs**: Subscribe to transaction logs.

  `ws_client.on_logs { |logs_info| puts logs_info }`

- **Logs for a Specific Account**: Subscribe to logs related to a specific account.

  `ws_client.on_logs_for_account(account_pubkey) { |logs_info| puts logs_info }`

- **Logs for a Specific Program**: Subscribe to logs related to a specific program.

  `ws_client.on_logs_for_program(program_id) { |logs_info| puts logs_info }`

- **Root Change**: Subscribe to root changes.

  ws_client.on_root_change { |root_info| puts root_info }

- **Signature**: Subscribe to a signature notification.

  `ws_client.on_signature(signature) { |signature_info| puts signature_info }`

- **Slot Change**: Subscribe to slot changes.

  `ws_client.on_slot_change { |slot_info| puts slot_info }`

- **Unsubscribe Methods**: Each WebSocket method has a corresponding unsubscribe method:

  - remove_account_change_listener(subscription_id)
  - remove_program_account_listener(subscription_id)
  - remove_logs_listener(subscription_id)
  - remove_root_listener(subscription_id)
  - remove_signature_listener(subscription_id)
  - remove_slot_change_listener(subscription_id)

## Complete List of Available Methods

### HTTP Methods

The following methods are supported by the SolanaRuby::HttpClient:

#### Basic

    get_balance(pubkey)
    get_balance_and_context(pubkey)
    get_slot()
    get_epoch_info(options)
    get_epoch_schedule()
    get_genesis_hash()
    get_inflation_governor()
    get_inflation_rate()
    get_inflation_reward(addresses, options)
    get_leader_schedule(options)
    get_minimum_balance_for_rent_exemption(account_data_size, options)
    get_stake_activation(account_pubkey, options)
    get_stake_minimum_delegation(options)
    get_supply(options)
    get_version()
    get_total_supply(options)
    get_health()
    get_identity()
    get_recent_performance_samples(limit)
    get_recent_prioritization_fees(addresses)

#### Account

    get_account_info(pubkey)
    get_parsed_account_info(pubkey, options)
    get_account_info_and_context(pubkey, options)
    get_multiple_account_info(pubkeys, options)
    get_multiple_account_info_and_context(pubkeys, options)
    get_multiple_parsed_accounts(pubkeys, options)
    get_largest_accounts(options)
    get_program_accounts(program_id, options)
    get_parsed_program_accounts(program_id, options)
    get_vote_accounts(options)
    get_parsed_token_accounts_by_owner(owner_pubkey, filters, options)
    get_nonce_and_context(pubkey)
    get_nonce(pubkey)

#### Block

    get_nonce(pubkey)
    get_block(slot, options)
    get_block_production()
    get_block_time(slot)
    get_block_signatures(slot, options)
    get_cluster_nodes()
    get_confirmed_block(slot, options)
    get_confirmed_block_signatures(slot)
    get_parsed_block(slot, options)
    get_first_available_block()
    get_blocks_with_limit(start_slot, limit)
    get_block_height()
    get_block_commitment(block_slot)

#### Blockhash

    get_latest_blockhash()
    get_latest_blockhash()
    get_fee_for_message(blockhash, options)
    is_blockhash_valid?(blockhash, options)

#### Lookup Table

    get_address_lookup_table(pubkey)

#### Signature

    get_signature_statuses(signatures)
    get_signature_status(signature, options)
    get_signatures_for_address(address, options)

#### Slot

    get_slot()
    get_slot_leader(options)
    get_slot_leaders(start_slot, limit)
    get_highest_snapshot_slot()
    get_minimum_ladger_slot()
    get_max_retransmit_slot()
    get_max_shred_insert_slot()

#### Token

    get_token_balance(pubkey, options)
    get_token_supply(pubkey)
    get_token_accounts_by_owner(owner_pubkey, filters, options)
    get_token_largest_accounts(mint_pubkey, options)

#### Transaction

    send_transaction(signed_transaction, options)
    confirm_transaction(signature, commitment, timeout)
    get_transaction(signature, options)
    get_transaction_count(options)
    get_transactions(signatures, options)
    request_airdrop(pubkey, lamports, options)
    simulate_transaction(transaction, options)
    send_encoded_transaction(encoded_transaction, options)
    send_raw_transaction(raw_transaction, options)

### WebSocket Methods

The following methods are supported by the SolanaRuby::WebSocketClient:

    on_account_change(pubkey, options)
    on_program_account_change(program_id, options, filters)
    on_logs(options=['all'])
    on_logs_for_account(public_key)
    on_logs_for_program(program_id)
    on_root_change()
    on_signature(signature)
    on_signature_with_options(signature, options)
    remove_account_change_listener(subscription_id)
    remove_program_account_listener(subscription_id)
    remove_logs_listener(subscription_id)
    remove_root_listener(subscription_id)
    remove_signature_listener(subscription_id)
    remove_slot_change_listener(subscription_id)

## Default Options

Several methods have optional parameters where default options are defined in the client. These options can be customized or overridden when calling the methods, but if left unspecified, the client will use its internal defaults.

## Transaction Helpers

### Transfer SOL Between Accounts

To transfer SOL (the native cryptocurrency of the Solana blockchain) from one account to another, follow these steps:

#### Requirements:

- **Sender's Keypair:** Either generate a new keypair or provide the private key for an existing sender account. This keypair is used to sign the transaction.
- **Receiver's Public Key:** Specify the public key of the destination account. You can generate a new keypair for the receiver or use an existing public key.
- **Airdrop Functionality:** For Mainnet, Devnet, or Testnet transactions, ensure that the sender's account is funded with sufficient lamports using the Solana airdrop feature.
- An initialized client to interact with the Solana blockchain.

#### Example Usage:

```ruby
require 'solana_ruby'

# Initialize the client (defaults to Mainnet(https://api.mainnet-beta.solana.com))
client = SolanaRuby::HttpClient.new('https://api.devnet.solana.com')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Generate or fetch the sender's keypair
# Option 1: Generate a new keypair
sender_keypair = SolanaRuby::Keypair.generate
# Option 2: Use an existing private key
# sender_keypair = SolanaRuby::Keypair.from_private_key("InsertPrivateKeyHere")

sender_pubkey = sender_keypair[:public_key]


# Airdrop some lamports to the sender's account when needed.
lamports = 10 * 1_000_000_000
sleep(1)
result = client.request_airdrop(sender_pubkey, lamports)
puts "Solana Balance #{lamports} lamports added sucessfully for the public key: #{sender_pubkey}"
sleep(10)


# Generate or use an existing receiver's public key
# Option 1: Generate a new keypair for the receiver
receiver_keypair = SolanaRuby::Keypair.generate
receiver_pubkey = receiver_keypair[:public_key]
# Option 2: Use an existing public key
# receiver_pubkey = 'InsertExistingPublicKeyHere'

transfer_lamports = 1 * 1_000_000
puts "Payer's full private key: #{sender_keypair[:full_private_key]}"
puts "Receiver's full private key: #{receiver_keypair[:full_private_key]}"
puts "Receiver's Public Key: #{receiver_keypair[:public_key]}"

# Create a new transaction
transaction = SolanaRuby::TransactionHelper.sol_transfer(
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
```

### Account Creation

The create_account helper allows creating a new account with specified parameters. This is commonly used to set up accounts for tokens, programs, or other allocations on the Solana blockchain.

#### Requirements:

- **Payer Public key**: The public key of the account funding the creation.
- **New Account Public Key**: The public key of the account to be created.
- **Lamports**: The amount of lamports to transfer to the new account.
- **Space**: The amount of space (in bytes) to allocate for the new account.
- **Recent Blockhash**: The latest blockhash for the transaction.
- **Program Id**: The program ID associated with the new account (default: System Program).

#### Example Usage:

```ruby
require 'solana_ruby'

# Initialize the client (defaults to Mainnet(https://api.mainnet-beta.solana.com))
client = SolanaRuby::HttpClient.new('https://api.devnet.solana.com')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Generate or fetch the sender/payer keypair
# Option 1: Generate a new keypair
sender_keypair = SolanaRuby::Keypair.generate
# Option 2: Use an existing private key
# sender_keypair = SolanaRuby::Keypair.from_private_key("InsertPrivateKeyHere")
sender_pubkey = sender_keypair[:public_key]

# Generate new account keypair
new_account = SolanaRuby::Keypair.generate
new_account_pubkey = new_account[:public_key]

# Parameters for account creation
lamports = 1_000_000_000
space = 165
program_id = SolanaRuby::TransactionHelper::SYSTEM_PROGRAM_ID

# Create the account creation transaction
transaction = SolanaRuby::TransactionHelper.create_account(
  sender_pubkey,
  new_account_pubkey,
  lamports,
  space,
  recent_blockhash,
  program_id
)

# Sign with both keypairs
transaction.sign([sender_keypair, new_account])

# Send the transaction
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"
puts "New account created with Public Key: #{new_account_pubkey}"
```

### SPL Token Account Creation

The create_associated_token_account helper allows you to create an associated token account for a specific mint and owner. This is necessary when dealing with SPL tokens on the Solana blockchain.

#### Requirements:

- **Payer Public key**: The public key of the account funding the creation.
- **Mint Public Key**: The public key of the SPL token mint.
- **Owner Public Key**: The public key of the owner for whom the associated token account is being created.
- **Recent Blockhash**: The latest blockhash for the transaction.

#### Example Usage:

```ruby
require 'solana_ruby'

# Initialize the Solana client (defaults to Mainnet: https://api.mainnet-beta.solana.com)
client = SolanaRuby::HttpClient.new('https://api.devnet.solana.com')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Load the keypair for the payer
payer_keypair = SolanaRuby::Keypair.load_keypair('InsertYourJsonFilePathHere')
payer_pubkey = payer_keypair.public_key

# Generate or load the owner keypair
owner_keypair = SolanaRuby::Keypair.generate
owner_pubkey = owner_keypair.public_key

puts "Owner Public Key: #{owner_pubkey}"
puts "Owner Private Key: #{owner_keypair.private_key}"

# Define the mint public key for the SPL token
mint_pubkey = "InsertMintPublicKeyHere"

# Create the associated token account transaction
transaction = SolanaRuby::TransactionHelper.create_associated_token_account(
  payer_pubkey,
  mint_pubkey,
  owner_pubkey,
  recent_blockhash
)

# Sign the transaction
transaction.sign([payer_keypair])

# Send the transaction
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"
```

### Close Account

The close_account helper allows you to close an associated token account on the Solana blockchain. Any remaining balance in the account is transferred to the specified destination account.

#### Requirements:

- **Account to Close**: The public key of the associated token account to be closed.
- **Destination Public Key**: The public key of the account receiving the remaining balance.
- **Owner Public Key**: The public key of the account owner who has permission to close the account.
- **Payer Public Key**: The public key of the account paying for the transaction fees.
- **Multi-Signers (Optional)**: An array of additional signer public keys if the account requires multiple signatures.
- **Recent Blockhash**: The latest blockhash for the transaction.

#### Example Usage:

```ruby
require 'solana_ruby'

# Initialize the Solana client (defaults to Mainnet: https://api.mainnet-beta.solana.com)
client = SolanaRuby::HttpClient.new('https://api.devnet.solana.com')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Load the keypairs
payer_keypair = SolanaRuby::Keypair.from_private_key("InsertPayerPrivateKeyHere")
owner_keypair = SolanaRuby::Keypair.from_private_key("InsertOwnerPrivateKeyHere")

payer_pubkey = payer_keypair[:public_key]
owner_pubkey = owner_keypair[:public_key]

# Define the associated token account to be closed and the destination account
account_to_close_pubkey = 'InsertAccountToClosePublicKeyHere'  # Replace with the actual account to close
destination_pubkey = 'InsertDestinationPublicKeyHere'  # Replace with the actual recipient address

# Multi-signers (if required)
# multi_signers = [SolanaRuby::Keypair.from_private_key("InsertAdditionalSignerPrivateKeyHere")]
multi_signers = []

# Extract public keys of multi-signers
multi_signer_pubkeys = multi_signers.map { |signer| signer[:public_key] }

# Create the close account transaction
transaction = SolanaRuby::TransactionHelper.close_account(
  account_to_close_pubkey,
  destination_pubkey,
  owner_pubkey,
  payer_pubkey,
  multi_signer_pubkeys,
  recent_blockhash
)

# Sign the transaction
transaction.sign([payer_keypair, owner_keypair])

# Send the transaction
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"
puts "Closed account: #{account_to_close_pubkey}, funds sent to: #{destination_pubkey}"
```

### Get Associated Token Address

The get_associated_token_address helper fetches the associated token account for a given mint address and owner public key. This is essential when interacting with SPL tokens to determine where tokens are held.

#### Requirements:

- **Mint Address**: The public key of the SPL token mint.
- **Owner Public Key**: The public key of the token holder.

#### Example Usage:

```ruby
require 'solana_ruby'

# Define mint address and owner public key
mint_address = 'InsertMintPublicKeyHere'
owner_pubkey = 'InsertOwnerPublicKeyHere'

# Fetch associated token address
associated_token_address = SolanaRuby::TransactionHelpers::TokenAccount.get_associated_token_address(
  mint_address,
  owner_pubkey
)

puts "Associated Token Address: #{associated_token_address}"
```

### Mint SPL Tokens

The mint_spl_tokens helper allows you to mint new SPL tokens to a specified destination account. This is useful for token creators who need to distribute newly minted tokens.

#### Requirements:

- **Mint Account Public Key**: The public key of the mint account.
- **Destination Account Public Key**: The associated token account where the newly minted tokens will be sent.
- **Mint Authority Public Key**: The public key of the authority allowed to mint new tokens.
- **Amount**: The number of tokens to mint (in the smallest unit, based on token decimals).
- **Multi-Signers (Optional)**: Additional signer public keys if multi-signature authorization is required.
- **Recent Blockhash**: The latest blockhash for the transaction.

#### Example Usage:

```ruby
require 'solana_ruby'

# Initialize the Solana client (defaults to Mainnet: https://api.mainnet-beta.solana.com)
client = SolanaRuby::HttpClient.new('https://api.devnet.solana.com')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Define the mint account and recipient
mint_account = "InsertMintPublicKeyHere"
destination_account = "InsertDestinationPublicKeyHere"

# Load the mint authority keypair
mint_authority = SolanaRuby::Keypair.load_keypair('InsertYourJsonFilePathHere')

puts "Mint Authority Public Key: #{mint_authority[:public_key]}"

# Define the amount to mint (in smallest units)
amount = 1_000_000_00_00 # Adjust based on token decimals

# Multi-signers (if required)
multi_signers = [] # Example: [additional_signer_pubkey]

# Create the mint transaction
transaction = SolanaRuby::TransactionHelper.mint_spl_tokens(
  mint_account,
  destination_account,
  mint_authority[:public_key],
  amount,
  recent_blockhash,
  multi_signers
)

# Sign the transaction with the mint authority
transaction.sign([mint_authority])

# Send the transaction
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"
puts "Minted #{amount} tokens to: #{destination_account}"
```

### Burn SPL Tokens

The burn_spl_tokens helper allows you to burn (destroy) a specified amount of SPL tokens from a token account. This is typically used to reduce the total supply of a token.

#### Requirements:

- **Token Account**: The associated token account holding the tokens to be burned..
- **Mint Address**: The mint address of the SPL token.
- **Owner**: The owner of the token account (must have authority to burn tokens).
- **Amount**: The number of tokens to burn (denominated in the smallest units).
- **Recent Blockhash**: The latest blockhash for the transaction.

#### Example Usage:

```ruby
require 'solana_ruby'

# Initialize the Solana client (defaults to Mainnet: https://api.mainnet-beta.solana.com)
client = SolanaRuby::HttpClient.new('https://api.devnet.solana.com')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Define token account and mint address
token_account = "InsertTokenAccountPublicKeyHere"
mint_address = "InsertMintPublicKeyHere"

# Load the mint authority keypair
mint_authority = SolanaRuby::Keypair.load_keypair('/path/to/id.json')
owner = mint_authority[:public_key]

# Define the amount to burn
amount = 500_000 # Tokens to burn in smallest units

# Create burn transaction
transaction = SolanaRuby::TransactionHelper.burn_spl_tokens(
  token_account,
  mint_address,
  owner,
  amount,
  recent_blockhash
)

# Sign the transaction
transaction.sign([mint_authority])

# Send the transaction
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"
```

### Transfer SPL Tokens

The new_spl_token_transaction helper allows you to transfer SPL tokens from one associated token account to another.

#### Requirements:

- **Sender's Token Account**: The associated token account holding the tokens to be transferred.
- **Mint Address**: The mint address of the SPL token.
- **Receiver's Token Account**: The associated token account of the recipient.
- **Fee Payer:**: The account responsible for transaction fees.
- **Amount**: The number of tokens to mint (in the smallest unit, based on token decimals).
- **Decimals**: The decimal precision of the SPL token (e.g., 9 for SOL-based tokens).
- **Recent Blockhash**: The latest blockhash for the transaction.
- **Multi-Signers (Optional)**: List of additional required signers (if applicable).

#### Example Usage:

```ruby
require 'solana_ruby'

# Initialize the Solana client
client = SolanaRuby::HttpClient.new('http://127.0.0.1:8899')

# Fetch the recent blockhash
recent_blockhash = client.get_latest_blockhash["blockhash"]

# Load the fee payer's keypair
fee_payer = SolanaRuby::Keypair.from_private_key('InsertFeePayerPrivateKeyHere')
fee_payer_pubkey = fee_payer[:public_key]

# Define the SPL token mint address
mint_address = 'InsertMintPublicKeyHere'

# Define sender and receiver public keys
sender_pubkey = 'InsertSenderPublicKeyHere'
receiver_pubkey = 'InsertReceiverPublicKeyHere'

# Fetch the associated token accounts
senders_token_account = SolanaRuby::TransactionHelpers::TokenAccount.get_associated_token_address(mint_address, sender_pubkey)
receivers_token_account = SolanaRuby::TransactionHelpers::TokenAccount.get_associated_token_address(mint_address, receiver_pubkey)

puts "Sender's Token Account: #{senders_token_account}"
puts "Receiver's Token Account: #{receivers_token_account}"

# Define the transfer amount and decimals
transfer_lamports = 1_000_000 # Amount in smallest units
decimals = 9 # Adjust based on token precision

# Multi-signers (Optional, default is an empty array)
# multi_signers = [
#  SolanaRuby::Keypair.from_private_key('InsertMultiSigner1PrivateKeyHere'),
#  SolanaRuby::Keypair.from_private_key('InsertMultiSigner2PrivateKeyHere')
# ]
# multi_signer_pubkeys = multi_signers.map { |signer| signer[:public_key] }
multi_signers = []

# Create the transaction
transaction = SolanaRuby::TransactionHelper.new_spl_token_transaction(
  senders_token_account,
  mint_address,
  receivers_token_account,
  fee_payer_pubkey,
  transfer_lamports,
  decimals,
  recent_blockhash,
  multi_signer_pubkeys
)

# Sign the transaction (Only fee payer, unless multi-signers are provided)
transaction.sign([fee_payer] + multi_signers)

# Send the transaction
puts "Sending transaction..."
response = client.send_transaction(transaction.to_base64, { encoding: 'base64' })

# Output transaction results
puts "Transaction Signature: #{response}"
```
