# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::BlockhashMethods do
  let(:url) { "https://api.mainnet-beta.solana.com" }
  let(:client) { SolanaRuby::HttpClient.new(url) }

   describe '#get_latest_blockhash and #get_latest_blockhash_and_context' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: {
          context: {
            apiVersion: '1.0.0',
            slot: 12345
          },
          value: {
            blockhash: 'someblockhash',
            lastValidBlockHeight: 654321
          }
        },
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(body: hash_including(method: 'getLatestBlockhash'))
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the current and available slot' do
      response = client.get_latest_blockhash()
      expect(response['blockhash']).to eq('someblockhash')
      expect(response['lastValidBlockHeight']).to eq(654321)
    end

    it 'returns the current and available slot' do
      response = client.get_latest_blockhash_and_context()
      expect(response['value']['blockhash']).to eq('someblockhash')
      expect(response['value']['lastValidBlockHeight']).to eq(654321)
      expect(response['context']['apiVersion']).to eq('1.0.0')
      expect(response['context']['slot']).to eq(12345)
    end
  end

  describe '#get_fee_calculator_for_blockhash' do
    let(:latest_blockhash) { '5GcB6bZC6f5EjSD7sxM2AfMkZpFX4hNTbjb54fMZghHC' }
    let(:params) { [latest_blockhash, { commitment: 'finalized' }] }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: {
          context: {
            apiVersion: '1.0.0',
            slot: 12345
          },
          value: {
            feeCalculator: {
              lamportsPerSignature: 1000
            }
          }
        },
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(body: hash_including(method: 'getFeeCalculatorForBlockhash', params: params))
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the current and available slot' do
      response = client.get_fee_calculator_for_blockhash(latest_blockhash)
      expect(response['context']['apiVersion']).to eq('1.0.0')
      expect(response['context']['slot']).to eq(12345)
      expect(response['value']['feeCalculator']['lamportsPerSignature']).to eq(1000)
    end
  end
end
