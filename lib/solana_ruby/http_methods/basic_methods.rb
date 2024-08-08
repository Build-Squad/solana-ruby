# frozen_string_literal: true

require 'pry'
require_relative '../../solana_ruby/exceptions/custom_error'

module SolanaRuby
  module HttpMethods
    module BasicMethods
      class SolanaError < StandardError; end

      def get_balance(pubkey)
        balance_info = request("getBalance", [pubkey])
        raise SolanaError, balance_info['error']['message'] if balance_info['error']

        balance_info["result"]["value"]
      end

      def get_balance_and_context(pubkey)
        balance_info = request("getBalance", [pubkey])
        balance_info["result"]
      end

      def get_account_info(pubkey)
        account_info = request("getAccountInfo", [pubkey])
        account_info["result"]["value"]
      end

      def get_account_info_and_context(pubkey)
        account_info = request("getAccountInfo", [pubkey])
        account_info["result"]
      end
    end
  end
end
