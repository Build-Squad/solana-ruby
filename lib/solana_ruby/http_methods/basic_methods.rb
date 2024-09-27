# frozen_string_literal: true

module SolanaRuby
  module HttpMethods
    # Basic Methods
    module BasicMethods
      FINALIZED_OPTIONS = { commitment: "finalized" }.freeze

      def get_balance(pubkey)
        balance_info = request("getBalance", [pubkey])
        balance_info["result"]["value"]
      end

      def get_balance_and_context(pubkey)
        balance_info = request("getBalance", [pubkey])
        balance_info["result"]
      end

      def get_epoch_info(options = FINALIZED_OPTIONS)
        epoch_info = request("getEpochInfo", [options])
        epoch_info["result"]
      end

      def get_epoch_schedule
        epoch_schedule = request("getEpochSchedule")
        epoch_schedule["result"]
      end

      def get_genesis_hash
        genesis_hash = request("getGenesisHash")
        genesis_hash["result"]
      end

      def get_inflation_governor
        inflation_governor = request("getInflationGovernor")
        inflation_governor["result"]
      end

      def get_inflation_rate
        inflation_rate = request("getInflationRate")
        inflation_rate["result"]
      end

      def get_inflation_reward(addresses, options = {})
        params = [addresses, options]
        request("getInflationReward", params)
      end

      def get_leader_schedule(options = { epoch: nil })
        leader_schedule = request("getLeaderSchedule", [options])
        leader_schedule["result"]
      end

      def get_minimum_balance_for_rent_exemption(account_data_size, options = FINALIZED_OPTIONS)
        params = [account_data_size, options]
        minimum_balance_for_rent_exemption = request("getMinimumBalanceForRentExemption", params)
        minimum_balance_for_rent_exemption["result"]
      end

      def get_stake_activation(account_pubkey, options = FINALIZED_OPTIONS.merge(epoch: nil))
        params = [account_pubkey, options]
        stake_activation = request("getStakeActivation", params)
        stake_activation["result"]
      end

      def get_stake_minimum_delegation(options = FINALIZED_OPTIONS)
        stake_minimum_delagation = request("getStakeMinimumDelegation", [FINALIZED_OPTIONS])
        stake_minimum_delagation["result"]
      end

      def get_supply(options = FINALIZED_OPTIONS)
        supply_info = request("getSupply", [options])
        supply_info["result"]
      end

      def get_version
        version_info = request("getVersion")
        version_info["result"]
      end

      def get_total_supply(options = FINALIZED_OPTIONS)
        supply_info = get_supply(options)
        supply_info["value"]["total"]
      end

      def get_health
        health_info = request("getHealth")
        health_info["result"]
      end

      def get_identity
        health_info = request("getIdentity")
        health_info["result"]
      end

      def get_recent_performance_samples(limit = 10)
        performance_samples = request("getRecentPerformanceSamples", [limit])
        performance_samples["result"]
      end

      def get_recent_prioritization_fees(addresses)
        params = [addresses]
        prioritization_fees = request("getRecentPrioritizationFees", params)
        prioritization_fees["result"]
      end
    end
  end
end
