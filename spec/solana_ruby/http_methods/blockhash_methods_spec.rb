# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::BlockhashMethods do
  let(:url) { "https://api.devnet.solana.com" }
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

  # describe '#get_fee_calculator_for_blockhash' do
  #   let(:latest_blockhash) { '5GcB6bZC6f5EjSD7sxM2AfMkZpFX4hNTbjb54fMZghHC' }
  #   let(:params) { [latest_blockhash, { commitment: 'finalized' }] }
  #   let(:response_body) do
  #     {
  #       jsonrpc: '2.0',
  #       result: {
  #         context: {
  #           apiVersion: '1.0.0',
  #           slot: 12345
  #         },
  #         value: {
  #           feeCalculator: {
  #             lamportsPerSignature: 1000
  #           }
  #         }
  #       },
  #       id: 1
  #     }.to_json
  #   end

  #   before do
  #     stub_request(:post, url)
  #       .with(body: hash_including(method: 'getFeeCalculatorForBlockhash', params: params))
  #       .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
  #   end

  #   it 'returns the current and available slot' do
  #     response = client.get_fee_calculator_for_blockhash(latest_blockhash)
  #     expect(response['context']['apiVersion']).to eq('1.0.0')
  #     expect(response['context']['slot']).to eq(12345)
  #     expect(response['value']['feeCalculator']['lamportsPerSignature']).to eq(1000)
  #   end
  # end
  describe '#get_fee_for_message' do
    let(:message) { "base64_encoded_message" }

    let(:fee_for_message_response) do
      {
        "jsonrpc" => "2.0",
        "result" => {
          "context"=> {
            "slot"=> 123456
          },
          "value" => 5000
        },
        "id" => 1
      }
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getFeeForMessage',
            params: [message, { commitment: 'processed' }]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: fee_for_message_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

  
    it 'returns the fee for the given message' do
      result = client.get_fee_for_message(message)
      expect(result['value']).to eq(5000)
      expect(result['context']['slot']).to eq(123456)
    end
  end

  describe '#is_blockhash_valid?' do
    let(:blockhash) { '5JN1NsW5Jt4TcXZjt9QVUMYV6Nqx4MBgHoAFUiy5vVmt' }
    let(:commitment) { 'processed' }

    let(:blockhash_valid_response) do
      {
        "jsonrpc"=> "2.0",
        "result"=> {
          "context"=> {
            "slot"=> 123456
          },
          "value"=> true
        },
        "id"=> 1
      }
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'isBlockhashValid',
            params: [blockhash, { commitment: commitment }]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: blockhash_valid_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns true when the blockhash is valid' do
      result = client.is_blockhash_valid?(blockhash)
      expect(result).to eq(true)
    end

    it 'handles invalid blockhashes correctly' do
      blockhash_valid_response['result']['value'] = false
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'isBlockhashValid',
            params: [blockhash, { commitment: commitment }]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: blockhash_valid_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = client.is_blockhash_valid?(blockhash)
      expect(result).to eq(false)
    end
  end
end
