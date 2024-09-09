# frozen_string_literal: true
require_relative 'signature_methods'

module SolanaRuby
  module HttpMethods
    module TransactionMethods
      DEFAULT_COMMITMENT = 'finalized'
      TIMEOUT = 60 # seconds
      RETRY_INTERVAL = 2 # seconds

      def send_transaction(signed_transaction, options = {})
        params = [signed_transaction, options]
        result = request('sendTransaction', params)
        result['result']
      end

      def confirm_transaction(signature, commitment = DEFAULT_COMMITMENT, timeout = TIMEOUT)
        start_time = Time.now
        
        loop do
          # Fetch transaction status
          options = { "searchTransactionHistory" => true }
          status_info = get_signature_status(signature, options)

          # Check if the transaction is confirmed based on the commitment level
          if status_info && (status_info['confirmationStatus'] == commitment || status_info['confirmationStatus'] == 'confirmed')
            return true
          end

          # Break the loop if timeout is reached
          if Time.now - start_time > timeout
            raise "Transaction #{signature} was not confirmed within #{timeout} seconds."
          end

          sleep(RETRY_INTERVAL)
        end
      end

      def get_transaction(signature, options = {})
        params = [signature, options]
        response = request('getTransaction', params)
        response['result']
      end

      def get_transaction_count(options = { commitment: 'finalized' })
        result = request('getTransactionCount', [options])
        result['result']
      end

      def get_transactions(signatures, options = { commitment: 'finalized' })
        transactions = []
        signatures.each do |signature|
          transaction = get_transaction(signature, options)
          transactions << transaction
        end
        transactions
      end

      def request_airdrop(pubkey, lamports, options = FINALIZED_OPTIONS)
        params = [pubkey, lamports, options]
        response = request('requestAirdrop', params)
        response['result']
      end

      def simulate_transaction(transaction, options = { encoding: 'base64' })
        params = [transaction, options]
        response = request('simulateTransaction', params)
        response['result']
      end

      def send_encoded_transaction(encoded_transaction, options = { commitment: 'confirmed' })
        send_transaction(encoded_transaction, options)
      end

      def send_raw_transaction(raw_transaction, options = {})
        # Convert the raw hexadecimal transaction to base64 encoding
        base64_encoded_transaction = Base64.encode64(raw_transaction)

        send_transaction(base64_encoded_transaction, options)
      end
    end
  end
end
