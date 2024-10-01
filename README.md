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

    require 'solana_ruby'

    # Initialize the client (defaults to Mainnet(https://api.mainnet-beta.solana.com))
    client = SolanaRuby::HttpClient.new()

    # Optionally, provide a custom RPC URL
    # client = SolanaRuby::HttpClient.new("https://api.devnet.solana.com")

### Fetch Solana Account Balance

Once the client is initialized, you can make API calls to the Solana network. For example, to get the solana balance of a given account:

    # Replace 'pubkey' with the actual public key of the solana account

    pubkey = 'Fg6PaFpoGXkYsidMpWxTWqSKJf6KJkUxX92cnv7WMd2J'

    result = client.get_balance(pubkey)

    puts result

### Fetch Parsed Account Info

    # Replace 'pubkey' with the actual public key of the account
    pubkey = 'Fg6PaFpoGXkYsidMpWxTWqSKJf6KJkUxX92cnv7WMd2J'

    # Example of options that can be passed:
    options = {
      commitment: 'finalized',   # Specifies the level of commitment for querying state (e.g., 'finalized', 'confirmed', 'processed')
      encoding: 'jsonParsed'     # Specifies the encoding format (e.g., 'jsonParsed', 'base64', etc.)
    }

    result = client.get_parsed_account_info(pubkey, options)

    puts result

### Options Parameter

The options parameter is a hash that can include the following fields:

commitment: Specifies the level of commitment desired when querying state.

Options include:

    'finalized': Query the most recent block confirmed by supermajority of the cluster.
    'confirmed': Query the most recent block that has been voted on by supermajority of the cluster.
    'processed': Query the most recent block regardless of cluster voting.

encoding: Defines the format of the returned account data. Possible values include:

    'jsonParsed': Returns data in a JSON-parsed format.
    'base64': Returns raw account data in Base64 encoding.
    'base64+zstd': Returns compressed Base64 data.

By providing options, you can control the nature of the returned data and the reliability of the query.

### Filters Parameter

The filters parameter allows you to specify conditions for querying token accounts. Some common filter types include:

    # Mint Filter: Filter by a specific token mint. This retrieves accounts holding tokens of that mint.
    filters = { mint: 'TokenMintPublicKey' }

    # Program Filter: Filter by a specific program (e.g., the token program).
    filters = { programId: 'TokenProgramPublicKey' }

## WebSocket Methods

The SolanaRuby gem also provides WebSocket methods to handle real-time notifications and updates from the Solana blockchain. To use the WebSocket client:

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

The following methods are supported by the WebSocketClient:

- **Account Change**: Subscribe to changes in an account's state.

    ```ws_client.on_account_change(pubkey) { |account_info| puts account_info }```

- **Program Account Change**: Subscribe to changes in accounts owned by a specific program.

    ```ws_client.on_program_account_change(program_id, filters) { |program_account_info| puts program_account_info }```

- **Logs**: Subscribe to transaction logs.

    ```ws_client.on_logs { |logs_info| puts logs_info }```

- **Logs for a Specific Account**: Subscribe to logs related to a specific account.

    ```ws_client.on_logs_for_account(account_pubkey) { |logs_info| puts logs_info }```

- **Logs for a Specific Program**: Subscribe to logs related to a specific program.

    ```ws_client.on_logs_for_program(program_id) { |logs_info| puts logs_info }```

- **Root Change**: Subscribe to root changes.

    ws_client.on_root_change { |root_info| puts root_info }

- **Signature**: Subscribe to a signature notification.

    ```ws_client.on_signature(signature) { |signature_info| puts signature_info }```

- **Slot Change**: Subscribe to slot changes.

    ```ws_client.on_slot_change { |slot_info| puts slot_info }```

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

