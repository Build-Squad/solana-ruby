# SolanaRuby

`SolanaRuby` is a lightweight Ruby client for interacting with the Solana blockchain through its JSON-RPC API. It allows developers to perform various queries on the Solana network such as fetching solana balance, acccount information, and more.

TODO: Delete this and the text above, and describe your gem

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

    require 'solana_ruby'

### Initialize the client (defaults to Mainnet)

By default, the client uses the Solana Mainnet RPC URL. You can initialize the client like this:

    client = SolanaRuby::HttpClient.new()

If you want to use a different Solana network (e.g., Devnet or Testnet), you can pass the desired RPC URL:

    client = SolanaRuby::HttpClient.new("https://api.devnet.solana.com")

### For Example

### Fetch Solana Account Balance

Once the client is initialized, you can make API calls to the Solana network. For example, to get the token supply of a given account:

    # Replace 'pubkey' with the actual public key of the token account

    pubkey = 'Fg6PaFpoGXkYsidMpWxTWqSKJf6KJkUxX92cnv7WMd2J'

    result = client.get_balance(pubkey)

    puts result

# Fetch Parsed Account Info

    # Replace 'pubkey' with the actual public key of the account
    pubkey = 'Fg6PaFpoGXkYsidMpWxTWqSKJf6KJkUxX92cnv7WMd2J'

    # Example of options that can be passed:
    options = {
      commitment: 'finalized',   # Specifies the level of commitment for querying state (e.g., 'finalized', 'confirmed', 'processed')
      encoding: 'jsonParsed'     # Specifies the encoding format (e.g., 'jsonParsed', 'base64', etc.)
    }

    result = client.get_parsed_account_info(pubkey, options)

    puts result

# Available Methods

The following methods are supported by the SolanaRuby::HttpClient:

    get_balance(pubkey)
    get_balance_and_context(pubkey)
    get_slot
    get_account_info(pubkey)
    get_parsed_account_info(pubkey, options)
    And more...

