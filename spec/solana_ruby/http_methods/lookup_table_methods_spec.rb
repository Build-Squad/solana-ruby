# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::LookupTableMethods do
  let(:url) { 'https://api.devnet.solana.com' }
  let(:client) { SolanaRuby::HttpClient.new(url) }

  describe '#get_address_lookup_table' do
    let(:pubkey) { '4aPUVcbh82duG6ChMkMxWS1W21aafQ2f6Sq7PFBcvsZM' }

    context 'when the account data is valid' do
      let(:valid_account_data) do
        Base64.strict_encode64([12345678, 87654321, 0, 0].pack("Q<Q<Q<") +
                                ('A'.b * 32) +
                                ('B'.b * 32) +
                                ('C'.b * 32))
      end

      before do
        stub_request(:post, url)
          .with(body: hash_including(method: 'getAccountInfo', params: [pubkey, {}]))
          .to_return(
            status: 200,
            body: {
              jsonrpc: '2.0',
              result: { value: { data: valid_account_data } },
              id: 1
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns the correct lookup table data' do
        result = client.get_address_lookup_table(pubkey)

        expect(result).to eq({
          last_extended_slot: 12345678,
          last_extended_block_height: 87654321,
          deactivation_slot: 0,
          addresses: [
            Base58.binary_to_base58('B'.b * 32, :bitcoin),
            Base58.binary_to_base58('C'.b * 32, :bitcoin)
          ],
          authority: Base58.binary_to_base58('A'.b * 32, :bitcoin)
        })
      end
    end

    context 'when the account data is invalid or not found' do
      before do
        stub_request(:post, url)
          .with(body: hash_including(method: 'getAccountInfo', params: [pubkey, {}]))
          .to_return(
            status: 200,
            body: {
              jsonrpc: '2.0',
              result: { value: nil },
              id: 1
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'raises an error' do
        expect { client.get_address_lookup_table(pubkey) }
          .to raise_error(SolanaRuby::SolanaError, 'Address Lookup Table not found or invalid account data.')
      end
    end
  end
end
