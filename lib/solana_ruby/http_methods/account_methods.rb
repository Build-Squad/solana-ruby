# frozen_string_literal: true

module SolanaRuby
  module HttpMethods
    module AccountMethods
      ENCODING_JSON_OPTIONS = { encoding: 'jsonParsed', commitment: 'finalized' }.freeze
      FINALIZED_OPTIONS = { commitment: 'finalized' }.freeze
      ENCODING_BASE58_OPTIONS = { encoding: 'base58' }.freeze

      def get_account_info(pubkey)
        account_info = get_account_info_and_context(pubkey)
        account_info['value']
      end

      def get_parsed_account_info(pubkey, options = ENCODING_JSON_OPTIONS)
        get_account_info_and_context(pubkey, options)
      end

      def get_account_info_and_context(pubkey, options = {})
        account_info = request('getAccountInfo', [pubkey, options])
        account_info['result']
      end

      def get_multiple_account_info(pubkeys, options = ENCODING_BASE58_OPTIONS)
        accounts_info = get_multiple_account_info_and_context(pubkeys, options)
        accounts_info['value']
      end

      def get_multiple_account_info_and_context(pubkeys, options = ENCODING_BASE58_OPTIONS)
        params = [pubkeys, options]
        accounts_info = request('getMultipleAccounts', params)
        accounts_info['result']
      end

      def get_multiple_parsed_accounts(pubkeys, options = ENCODING_JSON_OPTIONS)
        get_multiple_account_info_and_context(pubkeys, options)
      end

      def get_largest_accounts(options = ENCODING_BASE58_OPTIONS.merge(FINALIZED_OPTIONS))
        account_info = request('getLargestAccounts', [options])
        account_info['result']
      end

      def get_program_accounts(program_id, options = FINALIZED)
        params = [program_id, options]
        account_info = request('getProgramAccounts', params)
        account_info['result']
      end

      def get_program_accounts(program_id, options = FINALIZED)
        params = [program_id, options]
        account_info = request('getProgramAccounts', params)
        account_info['result']
      end

      def get_parsed_program_accounts(program_id, options = ENCODING_JSON_OPTIONS)
        get_program_accounts(program_id, options)
      end

      def get_vote_accounts(options = FINALIZED_OPTIONS)
        account_info = request('getVoteAccounts', [options])
        account_info['result']
      end

      def get_parsed_token_accounts_by_owner(owner_pubkey, filters = {}, options = ENCODING_JSON_OPTIONS)
        params = [owner_pubkey, filters, options]
        request('getTokenAccountsByOwner', params)
      end
    end
  end
end
