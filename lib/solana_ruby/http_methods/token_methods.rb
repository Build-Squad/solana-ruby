# frozen_string_literal: true

require 'pry'
require 'base58'

module SolanaRuby
  module HttpMethods
    module TokenMethods
      FINALIZED_OPTIONS = { commitment: 'finalized' }.freeze

      def get_token_balance(pubkey, options = FINALIZED_OPTIONS)
        balance_info = request('getTokenAccountBalance', [pubkey, options])
        balance_info['result']['value']
      end

      def get_token_supply(pubkey)
        balance_info = request('getTokenSupply', [pubkey])
        balance_info['result']['value']
      end

      def get_token_accounts_by_owner(owner_pubkey, filters = {}, options = {})
        params = [owner_pubkey, filters, options]
        response = request('getTokenAccountsByOwner', params)
        response['result']
      end

      def get_token_largest_accounts(mint_pubkey, options = {})
        params = [mint_pubkey, options]
        response = request('getTokenLargestAccounts', params)
        response['result']
      end
    end
  end
end
