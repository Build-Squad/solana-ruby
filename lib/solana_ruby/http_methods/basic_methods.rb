# frozen_string_literal: true

require 'pry'
require 'base58'

module SolanaRuby
  module HttpMethods
    module BasicMethods

      def get_balance(pubkey)
        balance_info = request('getBalance', [pubkey])
        balance_info['result']['value']
      end

      def get_balance_and_context(pubkey)
        balance_info = request('getBalance', [pubkey])
        balance_info['result']
      end

      def get_account_info(pubkey)
        account_info = request('getAccountInfo', [pubkey])
        account_info['result']['value']
      end

      def get_account_info_and_context(pubkey)
        account_info = request('getAccountInfo', [pubkey])
        account_info['result']
      end

      def get_slot
        slot_info = request('getSlot')
        slot_info['result']
      end

      def get_epoch_info(options = { commitment: 'finalized' })
        epoch_info = request('getEpochInfo', [options])
        epoch_info['result']
      end

      def get_epoch_schedule
        epoch_schedule = request('getEpochSchedule')
        epoch_schedule['result']
      end

      def get_genesis_hash
        genesis_hash = request('getGenesisHash')
        genesis_hash['result']
      end

      def get_inflation_governor
        inflation_governor = request('getInflationGovernor')
        inflation_governor['result']
      end

      def get_inflation_rate
        inflation_rate = request('getInflationRate')
        inflation_rate['result']
      end

      def get_inflation_reward(addresses, options = {})
        params = [addresses, options]
        request('getInflationReward', params)
      end
    end
  end
end
