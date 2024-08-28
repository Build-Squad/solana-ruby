# frozen_string_literal: true

require 'base58'

module SolanaRuby
  module HttpMethods
    module LookupTableMethods

      def get_address_lookup_table(pubkey)
        response = get_account_info_and_context(pubkey)

        # Handle the response to ensure the account is a valid Address Lookup Table
        if response && response['value']
          account_data = response['value']['data']
          
          # Decode the account data
          lookup_table_data = decode_lookup_table_data(Base64.decode64(account_data))

          # Return the parsed lookup table details
          lookup_table_data
        else
          raise SolanaError.new('Address Lookup Table not found or invalid account data.')
        end
      end

      private

      def decode_lookup_table_data(data)
        lookup_table_state = {}

        lookup_table_state[:last_extended_slot], 
        lookup_table_state[:last_extended_block_height], 
        deactivation_slot = data[0, 24].unpack("Q<Q<Q<")

        lookup_table_state[:deactivation_slot] = (deactivation_slot == 0xFFFFFFFFFFFFFFFF) ? nil : deactivation_slot

        authority_offset = 24
        addresses_offset = authority_offset + 32

        authority_key = data[authority_offset, 32]
        lookup_table_state[:authority] = if authority_key == ("\x00" * 32)
                                           nil
                                         else
                                           Base58.binary_to_base58(authority_key, :bitcoin)
                                         end

        addresses_data = data[addresses_offset..-1]
        address_count = addresses_data.size / 32
        lookup_table_state[:addresses] = address_count.times.map do |i|
          address_data = addresses_data[i * 32, 32]
          Base58.binary_to_base58(address_data, :bitcoin)
        end
        
        lookup_table_state
      end
    end
  end
end