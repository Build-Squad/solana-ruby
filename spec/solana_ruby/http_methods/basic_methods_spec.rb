# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpClient do
  let(:url) { 'https://api.devnet.solana.com' }
  let(:client) { SolanaRuby::HttpClient.new(url) }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  describe '#get_balance' do
    context 'when the valid public key is available' do
      let(:pubkey) { '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g' }
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result: { value: 1000000 },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(body: hash_including(method: 'getBalance', params: [pubkey]))
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the balance of the given public key' do
        response = client.get_balance(pubkey)
        expect(response).to eq(1000000)
      end
    end

    context 'when the public key is not available or invalid' do
      let(:invalid_pubkey) { 'invalidPublicKey' }
      let(:error_response_body) do
        {
          jsonrpc: '2.0',
          error: {
            code: -32602,
            message: 'Invalid params: Invalid'
          },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(body: hash_including(method: 'getBalance', params: [invalid_pubkey]))
          .to_return(status: 200, body: error_response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises a RuntimeError with the error message' do
        expect { client.get_balance(invalid_pubkey) }.to raise_error(RuntimeError, 'An unexpected error occurred: API Error: -32602 - Invalid params: Invalid')
      end
    end

    context 'when the public key is size is wrong length' do
      let(:invalid_pubkey) { 'VuhCxzii1aMz5PvBCsZt9p4xhuaEpLHDa8ZbPJkP6' }
      let(:error_response_body) do
        {
          jsonrpc: '2.0',
          error: {
            code: -32602,
            message: 'Invalid params: WrongSize'
          },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(body: hash_including(method: 'getBalance', params: [invalid_pubkey]))
          .to_return(status: 200, body: error_response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises a RuntimeError with the wrongsize error message' do
        expect { client.get_balance(invalid_pubkey) }.to raise_error(RuntimeError, 'An unexpected error occurred: API Error: -32602 - Invalid params: WrongSize')
      end
    end
  end

  describe '#get_balance_and_context' do
    let(:pubkey) { '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g' }
    let(:response_body) do
      {
        result: {
          context: {
            apiVersion: "1.0.0",
            slot: 123456789
          },
          value: 1000000
        }
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(body: hash_including(method: 'getBalance', params: [pubkey]))
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the balance and context of the given public key' do
      response = client.get_balance_and_context(pubkey)
      expect(response['context']['apiVersion']).to eq('1.0.0')
      expect(response['context']['slot']).to eq(123456789)
      expect(response['value']).to eq(1000000)
    end
  end

  describe '#get_account_info and #get_account_info_and_context' do
    context 'when the public key is not available or invalid' do
      let(:pubkey) { '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g' }
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result:
          {
            context: {
              apiVersion: '1.0.0',
              slot: 123456789
            },
            value: {
              data: "",
              executable: false,
              lamports: 1000000,
              owner: "11111111111111111111111111111111",
              rentEpoch: 54534684155455,
              space: 0
            }
          },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(body: hash_including(method: 'getAccountInfo', params: [pubkey]))
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the account information of the given public key' do
        response = client.get_account_info(pubkey)
        expect(response['rentEpoch']).to eq(54534684155455)
        expect(response['lamports']).to eq(1000000)
      end

      it 'returns the account information along with context of the given public key' do
        response = client.get_account_info_and_context(pubkey)
        expect(response['context']['slot']).to eq(123456789)
        expect(response['context']['apiVersion']).to eq('1.0.0')
        expect(response['value']['rentEpoch']).to eq(54534684155455)
        expect(response['value']['lamports']).to eq(1000000)
      end
    end
  end
end
