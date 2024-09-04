# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::TokenMethods do
  let(:url) { "https://api.devnet.solana.com" }
  let(:client) { SolanaRuby::HttpClient.new(url) }
  let(:token_pubkey) { 'CQBoNEWHa8pFDdwuFeNsDaRfeVnLECZWC27zreSHDRUa' }
  let(:options) { { commitment: 'finalized' } }

  describe '#get_token_balance' do
    context 'when the request is successful' do
      before do
        response_body = {
          jsonrpc: '2.0',
          result: {
            context: { slot: 123456 },
            value: {
              uiAmount: 123.456,
              decimals: 6,
              amount: '123456000'
            }
          },
          id: 1
        }.to_json

        stub_request(:post, url)
          .with(body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getTokenAccountBalance',
            params: [token_pubkey, options]
          }.to_json)
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the token balance' do
        result = client.get_token_balance(token_pubkey, options)
        expect(result['uiAmount']).to eq(123.456)
        expect(result['decimals']).to eq(6)
        expect(result['amount']).to eq('123456000')
      end
    end

    context 'when the request fails with an API error' do
      before do
        error_response = {
          jsonrpc: '2.0',
          error: {
            code: -32600,
            message: 'Invalid request'
          },
          id: 1
        }.to_json

        stub_request(:post, url)
          .with(body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getTokenAccountBalance',
            params: [token_pubkey, options]
          }.to_json)
          .to_return(status: 400, body: error_response, headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises an API error' do
        expect { client.get_token_balance(token_pubkey) }.to raise_error(SolanaRuby::SolanaError, /Invalid request/)
      end
    end

    context 'when the request fails with a network error' do
      before do
        stub_request(:post, url)
          .with(body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getTokenAccountBalance',
            params: [token_pubkey, options]
          }.to_json)
          .to_raise(SocketError)
      end

      it 'raises a SocketError' do
        expect { client.get_token_balance(token_pubkey) }.to raise_error(SolanaRuby::SolanaError, /Failed to connect to the server/)
      end
    end

    context 'when the request times out' do
      before do
        stub_request(:post, url)
          .with(body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getTokenAccountBalance',
            params: [token_pubkey, options]
          }.to_json)
          .to_raise(Timeout::Error)
      end

      it 'raises a TimeoutError' do
        expect { client.get_token_balance(token_pubkey) }.to raise_error(SolanaRuby::SolanaError, /Request timed out/)
      end
    end
  end

  describe '#get_token_supply' do
    context 'when the request is successful' do
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result: {
            context: {
              slot: 12345678
            },
            value: {
              amount: '1000000000',
              decimals: 9,
              uiAmount: 1000.0,
              uiAmountString: '1000.0'
            }
          },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'getTokenSupply',
              params: [token_pubkey]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body)
      end

      it 'returns the token supply for the given token' do
        result = client.get_token_supply(token_pubkey)
        expect(result['amount']).to eq('1000000000')
        expect(result['decimals']).to eq(9)
        expect(result['uiAmount']).to eq(1000.0)
        expect(result['uiAmountString']).to eq('1000.0')
      end
    end

    context 'when the API returns an error' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: { jsonrpc: '2.0', error: { code: -32600, message: 'Invalid request' }, id: 1 }.to_json)
      end

      it 'raises an API Error' do
        expect { client.get_token_supply(token_pubkey) }.to raise_error(SolanaRuby::SolanaError, /API Error: -32600 - Invalid request/)
      end
    end

    context 'when the request fails with a network error' do
      before do
        stub_request(:post, url)
          .with(body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getTokenSupply',
            params: [token_pubkey]
          }.to_json)
          .to_raise(SocketError)
      end

      it 'raises a SocketError' do
        expect { client.get_token_supply(token_pubkey) }.to raise_error(SolanaRuby::SolanaError, /Failed to connect to the server/)
      end
    end
  end

  describe '#get_token_accounts_by_owner' do
    let(:owner_pubkey) { '9mLs5EGBtCfEEV1wFuRAZwmyVQes7zTSqbvUbi25FD7P' }
    let(:token_program_id) { 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA' }
    let(:filters) { { mint: token_program_id } }
    context 'when the request is successful' do
      let(:response_body) do
        {
          jsonrpc: "2.0",
          result: {
            context: {
              slot: 12345678
            },
            value: [
              {
                pubkey: "3hKLQxkMF8TSMYfnV5uTxzy6p3U93Cdcnyq8XeyEAq8y",
                account: {
                  data: "example_data",
                  executable: false,
                  lamports: 2039280,
                  owner: token_program_id,
                  rentEpoch: 123
                }
              }
            ]
          },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'getTokenAccountsByOwner',
              params: [owner_pubkey, filters, {}]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body)
      end

      it 'returns the token accounts owned by the given public key' do
        result = client.get_token_accounts_by_owner(owner_pubkey, filters)
        expect(result['value']).to be_an(Array)
        expect(result['value'].first['pubkey']).to eq("3hKLQxkMF8TSMYfnV5uTxzy6p3U93Cdcnyq8XeyEAq8y")
        expect(result['value'].first['account']['lamports']).to eq(2039280)
      end
    end

    context 'when the API returns an error' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: { jsonrpc: "2.0", error: { code: -32600, message: "Invalid request" }, id: 1 }.to_json)
      end

      it 'raises an API Error' do
        expect { client.get_token_accounts_by_owner(owner_pubkey, filters) }.to raise_error(SolanaRuby::SolanaError, /API Error: -32600 - Invalid request/)
      end
    end

    context 'when there is a network error' do
      before do
        stub_request(:post, url)
          .with(body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getTokenAccountsByOwner',
            params: [owner_pubkey, filters, {}]
          }.to_json)
          .to_raise(SocketError)
      end

      it 'raises a SolanaError' do
        expect { client.get_token_accounts_by_owner(owner_pubkey, filters) }.to raise_error(SolanaRuby::SolanaError, /Failed to connect/)
      end
    end
  end
end
