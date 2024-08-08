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

      it 'raises a SolanaError with the correct message' do
        expect { client.get_balance(invalid_pubkey) }.to raise_error(SolanaRuby::HttpMethods::BasicMethods::SolanaError, 'Invalid params: Invalid')
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
end
