# frozen_string_literal: true

module SolanaRuby
  module HttpMethods
    module AccountMethods

      def get_account_info(pubkey)
        account_info = request('getAccountInfo', [pubkey])
        account_info['result']['value']
      end

      def get_account_info_and_context(pubkey)
        account_info = request('getAccountInfo', [pubkey])
        account_info['result']
      end

      def get_multiple_account_info(pubkeys, options = { encoding: 'base58' })
        accounts_info = get_multiple_account_info_and_context(pubkeys, options)
        accounts_info['value']
      end

      def get_multiple_account_info_and_context(pubkeys, options = { encoding: 'base58' })
        params = [pubkeys, options]
        accounts_info = request('getLargestAccounts', params)
        accounts_info['result']
      end

      def get_largest_accounts(options = { encoding: 'base58', commitment: 'finalized' })
        account_info = request('getLargestAccounts', [options])
        account_info['result']
      end

      def get_program_accounts(program_id, options = { commitment: 'finalized' })
        params = [program_id, options]
        account_info = request('getProgramAccounts', params)
        account_info['result']
      end

      def get_vote_accounts(options = { commitment: 'finalized' })
        account_info = request('getVoteAccounts', [options])
        account_info['result']
      end
    end
  end
end
