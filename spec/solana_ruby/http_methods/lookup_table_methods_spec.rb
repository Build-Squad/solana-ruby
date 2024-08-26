# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::LookupTableMethods do
  let(:url) { 'https://api.devnet.solana.com' }
  let(:client) { SolanaRuby::HttpClient.new(url) }
  
  describe '#get_address_lookup_table' do
    let(:pubkey) { '4aPUVcbh82duG6ChMkMxWS1W21aafQ2f6Sq7PFBcvsZM' }
    
    context 'when the account data is valid' do
      let(:valid_account_data) do
        # Replace this with actual binary data for a valid lookup table
        Base64.strict_encode64([12345678, 87654321, 0, 0].pack("Q<Q<Q<") +
                                ('A' * 32) +
                                ('B' * 32) +
                                ('C' * 32))
      end
      
      before do
        allow(client).to receive(:get_account_info_and_context)
          .with(pubkey)
          .and_return('value' => { 'data' => valid_account_data })
      end

      it 'returns the correct lookup table data' do
        result = client.get_address_lookup_table(pubkey)

        expect(result).to eq(
          "lastExtendedSlot" => 12345678,
          "lastExtendedBlockHeight" => 87654321,
          "deactivationSlot" => 18446744073709551615,
          "addresses" => [
            Base58.binary_to_base58('A' * 32, :bitcoin),
            Base58.binary_to_base58('B' * 32, :bitcoin),
            Base58.binary_to_base58('C' * 32, :bitcoin)
          ],
          "authority" => Base58.binary_to_base58('A' * 32, :bitcoin)
        )
      end
    end
    
    context 'when the account data is invalid' do
      before do
        allow(client).to receive(:get_account_info_and_context)
          .with(pubkey)
          .and_return('value' => nil)
      end

      it 'raises an error' do
        expect { client.get_address_lookup_table(pubkey) }
          .to raise_error("Address Lookup Table not found or invalid account data.")
      end
    end

    context 'when the address lookup table is not found' do
      before do
        allow(client).to receive(:get_account_info_and_context)
          .with(pubkey)
          .and_return('value' => { 'data' => Base64.strict_encode64('') })
      end

      it 'raises an error' do
        expect { client.get_address_lookup_table(pubkey) }
          .to raise_error("Address Lookup Table not found or invalid account data.")
      end
    end
  end
end
