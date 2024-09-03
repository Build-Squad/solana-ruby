# SolanaRuby

`SolanaRuby` is a lightweight Ruby client for interacting with the Solana blockchain through its JSON-RPC API. It allows developers to perform various queries on the Solana network such as fetching solana balance, acccount information, and more.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'solana_ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install solana_ruby

## Usage

To start using the Solana RPC client, initialize it with or without the RPC URL. The default URL points to the Solana Mainnet. If you wish to connect to another network like Devnet or Testnet, you can specify the URL.

    require 'solana_ruby'

    # Initialize the client (defaults to Mainnet)
    client = SolanaRuby::HttpClient.new()

    # Optionally, provide a custom RPC URL
    # client = SolanaRuby::HttpClient.new("https://api.devnet.solana.com")

## For Example

### Fetch Solana Account Balance

Once the client is initialized, you can make API calls to the Solana network. For example, to get the token supply of a given account:

    # Replace 'pubkey' with the actual public key of the token account

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

commitment: Specifies the level of commitment desired when querying state. Options include:
'finalized': Query the most recent block confirmed by supermajority of the cluster.
'confirmed': Query the most recent block that has been voted on by supermajority of the cluster.
'processed': Query the most recent block regardless of cluster voting.
encoding: Defines the format of the returned account data. Possible values include:
'jsonParsed': Returns data in a JSON-parsed format.
'base64': Returns raw account data in Base64 encoding.
'base64+zstd': Returns compressed Base64 data.
By providing options, you can control the nature of the returned data and the reliability of the query.

## Available Methods

The following methods are supported by the SolanaRuby::HttpClient:

    get_balance(pubkey)
    get_balance_and_context(pubkey)
    get_slot
    get_account_info(pubkey)
    get_parsed_account_info(pubkey, options)
    And more...

