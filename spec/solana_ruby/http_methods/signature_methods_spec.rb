# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::SignatureMethods do
  let(:url) { 'https://api.devnet.solana.com' }
  let(:client) { SolanaRuby::HttpClient.new(url) }
  let(:signatures) { ['4QV3nLZy8Z6oWynP7CuKV4XJwbCSiy3wzzSs2HRL5SrvrBqN4cxHGHPkBYeR2sQ5XPisFvPpEcthAynynvyu7YWp'] }
  let(:options) { { searchTransactionHistory: true } }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  describe '#get_signature_statuses' do
      before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getSignatureStatuses',
            params: [signatures, options]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: {
            result: {
              value: [
                {
                  slot: 12345,
                  confirmations: 10,
                  err: nil,
                  confirmationStatus: 'finalized',
                  status: { Ok: nil }
                }
              ]
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

  
    it 'returns the signature status data' do
      result = client.get_signature_statuses(signatures, options)
      expect(result['value'].first).to eq({
        'slot' => 12345,
        'confirmations' => 10,
        'err' => nil,
        'confirmationStatus' => 'finalized',
        "status"=>{ "Ok" => nil }
      })
    end

    context 'handles errors gracefully' do
      before do
        stub_request(:post, url)
          .with(
            body:{ jsonrpc: '2.0', id: 1, method: 'getSignatureStatuses', params: [signatures, options] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: { error: 'Internal Server Error' }.to_json)
      end

      it 'raises an error' do
        expect { client.getSignatureStatuses(signatures, options) }.to raise_error(StandardError)
      end
    end
  end

  describe '#get_signature_status' do
    before do
      # Stub the getSignatureStatuses request
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getSignatureStatuses',
            params: [[signatures[0]], options]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: {
            result: {
              context: { slot: 12345678 },
              value: [{
                confirmationStatus: 'finalized',
                confirmations: nil,
                err: nil,
                slot: 12345678,
                status: { Ok: nil }
              }]
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

  
    it 'returns the signature status' do
      result = client.get_signature_status(signatures[0], options)
      expect(result).to eq({
        "confirmationStatus" => "finalized",
        "confirmations" => nil,
        "err" => nil,
        "slot" => 12345678,
        "status"=>{ "Ok" => nil }
      })
    end

    context 'handles errors gracefully' do
      before do
        stub_request(:post, url)
          .with(
            body:{ jsonrpc: '2.0', id: 1, method: 'getSignatureStatuses', params: [[signatures[0]], options] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: { error: 'Internal Server Error' }.to_json)
      end

      it 'raises an error' do
        expect { client.get_signature_status(signatures[0], options) }.to raise_error(StandardError)
      end
    end
  end

  describe '#get_signatures_for_address' do
    let(:address) { 'BuqVvwzGAwjZ2mVsxCDpPaqBeJCZxoMWaK6k9pKznkyE' }
    let(:options) { { limit: 10 } } # Example options

    before do
      # Stub the getSignaturesForAddress request
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getSignaturesForAddress',
            params: [address, options]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: {
            result: {
              value: [
                { signature: '5h2MevnZdTVH7EtbrzPfTPAFKws7J7dpckvPtzavAhqW8XBw7Uj7sm2P6v7UasBAG8Uzk6UcAwW1VHDmCKfUxy2j', slot: 12345678 },
                { signature: '6h3MevnZdTVH7EtbrzPfTPAFKws7J7dpckvPtzavAhqW8XBw7Uj7sm2P6v7UasBAG8Uzk6UcAwW1VHDmCKfUxy3k', slot: 12345679 }
              ]
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns transaction signatures for the given address' do
      result = client.get_signatures_for_address(address, options)
      expect(result['value']).to eq([
        { 'signature' => '5h2MevnZdTVH7EtbrzPfTPAFKws7J7dpckvPtzavAhqW8XBw7Uj7sm2P6v7UasBAG8Uzk6UcAwW1VHDmCKfUxy2j', 'slot' => 12345678 },
        { 'signature' => '6h3MevnZdTVH7EtbrzPfTPAFKws7J7dpckvPtzavAhqW8XBw7Uj7sm2P6v7UasBAG8Uzk6UcAwW1VHDmCKfUxy3k', 'slot' => 12345679 }
      ])
    end
  end
end
