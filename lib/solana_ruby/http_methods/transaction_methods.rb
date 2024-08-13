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
          status = get_signature_status(signature, options)
          status_info = status['value'].first

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
    end
  end
end
