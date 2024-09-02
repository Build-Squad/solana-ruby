# frozen_string_literal: true

require 'pry'
require 'base58'

module SolanaRuby
  module HttpMethods
    module TokenMethods
      FINALIZED_OPTIONS = { commitment: 'finalized' }.freeze

      def get_token_balance(pubkey)
        balance_info = request('getTokenAccountBalance', [pubkey])
        balance_info['result']['value']
      end

      def get_token_supply(pubkey)
        balance_info = request('getTokenSupply', [pubkey])
        balance_info['result']['value']
      end
    end
  end
end
