# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::AccountMethods do
  let(:url) { 'https://api.devnet.solana.com' }
  let(:client) { SolanaRuby::HttpClient.new(url) }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  describe '#get_account_info and #get_account_info_and_context' do
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
        .with(body: hash_including(method: 'getAccountInfo', params: [pubkey, {}]))
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

  describe '#get_parsed_account_info' do
    let(:pubkey) { '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g' }
    let(:options) { { encoding: 'jsonParsed', commitment: 'finalized' } }
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
        .with(body: hash_including(method: 'getAccountInfo', params: [pubkey, options]))
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the parsed account information of the given public key' do
      response = client.get_parsed_account_info(pubkey, options)
      expect(response['context']['slot']).to eq(123456789)
      expect(response['context']['apiVersion']).to eq('1.0.0')
      expect(response['value']['rentEpoch']).to eq(54534684155455)
      expect(response['value']['lamports']).to eq(1000000)
    end
  end

  describe '#get_multiple_account_info#get_multiple_account_info_and_context#get_multiple_parsed_accounts' do
    let(:pubkeys) { ['ArBN2sDgpqjWEmr2Vk5WUHTC3SmusWYzMCTaA9rZ6itT', 'Ap4BqwYoXUD6JpjyPAiXX3JFX2FtBVBkpPFJGKQAyNX5'] }
    let(:options) { { encoding: 'base58' } }
    let(:valid_response) do
      {
        jsonrpc: '2.0',
        result: {
          context: { slot: 100 },
          value: [
            {
              pubkey: pubkeys[0],
              account: {
                data: {
                  parsed: {
                    info: { tokenAmount: { amount: '5000' } },
                    type: 'account'
                  },
                  lamports: 2039280,
                  owner: 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
                  rentEpoch: 234
                }
              }
            },
            {
              pubkey: pubkeys[1],
              account: {
                data: {
                  parsed: {
                    info: { tokenAmount: { amount: '10000' } },
                    type: 'account'
                  },
                  lamports: 3058290,
                  owner: 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
                  rentEpoch: 234
                }
              }
            }
          ]
        },
        id: 1
      }.to_json
    end

    let(:error_response_body) do
      {
        jsonrpc: '2.0',
        error: {
          code: 500,
          message: 'Internal server error'
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
            method: 'getMultipleAccounts',
            params: [pubkeys, options]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: valid_response, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns information for multiple accounts' do
      result = client.get_multiple_account_info(pubkeys, options)

      expect(result.size).to eq(2)
      expect(result.first['pubkey']).to eq(pubkeys[0])
      expect(result.last['account']['data']['parsed']['info']['tokenAmount']['amount']).to eq('10000')
    end

    it 'returns information for multiple accounts along with context info' do
      result = client.get_multiple_account_info_and_context(pubkeys, options)

      expect(result['context']['slot']).to eq(100)
      expect(result['value'].size).to eq(2)
      expect(result['value'].last['pubkey']).to eq(pubkeys[1])
      expect(result['value'].last['account']['data']['lamports']).to eq(3058290)
      expect(result['value'].last['account']['data']['rentEpoch']).to eq(234)
      expect(result['value'].last['account']['data']['owner']).to eq('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA')
    end

    context 'when the get_multiple_parsed_accounts is called'  do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'getMultipleAccounts',
              params: [pubkeys, { encoding: 'jsonParsed', commitment: 'finalized' }]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: valid_response)
      end

      it 'returns json parsed information for multiple accounts' do
        result = client.get_multiple_parsed_accounts(pubkeys, options)

        expect(result['context']['slot']).to eq(100)
        expect(result['value'].size).to eq(2)
        expect(result['value'].last['pubkey']).to eq(pubkeys[1])
        expect(result['value'].last['account']['data']['lamports']).to eq(3058290)
        expect(result['value'].last['account']['data']['rentEpoch']).to eq(234)
        expect(result['value'].last['account']['data']['owner']).to eq('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA')
      end
    end

    context 'when an error occurs' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'getMultipleAccounts',
              params: [pubkeys, options]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: error_response_body)
      end

      it 'raises an error' do
        expect { client.get_multiple_account_info(pubkeys, options) }
          .to raise_error(SolanaRuby::SolanaError, 'An unexpected error occurred: HTTP Error: 500 - Internal server error')
      end
    end
  end

  describe '#get_largest_accounts' do
    before do
      @successful_response = {
        result: [
          { pubkey: 'Account1', lamports: 1_000_000_000 },
          { pubkey: 'Account2', lamports: 500_000_000 }
        ]
      }
      
      # Define a failed response body
      @failed_response = { 'error' => { 'code' => -32602, 'message' => 'Invalid params' } }
      @options = { encoding: 'base58', commitment: 'finalized' }
    end

    it 'returns largest accounts when the request is successful' do
      stub_request(:post, url)
        .with(body: { jsonrpc: '2.0', id: 1, method: 'getLargestAccounts', params: [@options] }.to_json)
        .to_return(status: 200, body: @successful_response.to_json, headers: { 'Content-Type' => 'application/json' })

      response = client.get_largest_accounts
      expect(response).to be_an(Array)
      expect(response.first).to have_key('pubkey')
      expect(response.first).to have_key('lamports')
    end

    it 'raises an error when the request fails' do
      stub_request(:post, url)
        .with(body: { jsonrpc: '2.0', id: 1, method: 'getLargestAccounts', params: [@options] }.to_json)
        .to_return(status: 400, body: @failed_response.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { client.get_largest_accounts }.to raise_error(SolanaRuby::SolanaError, /Invalid params/)
    end

    it 'raises an error for invalid JSON response' do
      stub_request(:post, url)
        .with(body: { jsonrpc: '2.0', id: 1, method: 'getLargestAccounts', params: [@options] }.to_json)
        .to_return(status: 200, body: 'invalid json', headers: { 'Content-Type' => 'application/json' })

      expect { client.get_largest_accounts }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response/)
    end

    it 'handles timeout errors gracefully' do
      stub_request(:post, url)
        .with(body: { jsonrpc: '2.0', id: 1, method: 'getLargestAccounts', params: [@options] }.to_json)
        .to_timeout

      expect { client.get_largest_accounts }.to raise_error(SolanaRuby::SolanaError, /Request timed out/)
    end

    it 'handles connection errors gracefully' do
      stub_request(:post, url)
        .with(body: { jsonrpc: '2.0', id: 1, method: 'getLargestAccounts', params: [@options] }.to_json)
        .to_raise(SocketError)

      expect { client.get_largest_accounts }.to raise_error(SolanaRuby::SolanaError, /Failed to connect to the server/)
    end
  end

  describe '#get_program_accounts' do
    before do
      @successful_response = {
        result: [
          { account: { data: '3EdTv9xm4GHGr4UFE', executable: true, lamports: 1, owner: 'NativeLoader1111111111111111111111111111111', rentEpoch: 18446744073709551615, space: 12 }, pubkey: 'Vote111111111111111111111111111111111111111' },
          { account: { data: '25tu17Wz9P3BLFnPuJbEereG', executable: true, lamports: 1, owner: 'NativeLoader1111111111111111111111111111111', rentEpoch: 18446744073709551615, space: 17}, pubkey: 'KeccakSecp256k11111111111111111111111111111' }
        ]
      }

      @failed_response = { error: { code: -32602, message: 'Invalid params' } }
      @options = { commitment: 'finalized' }
    end

    it 'returns program accounts when the request is successful' do
      stub_request(:post, url)
        .with(body: { jsonrpc: '2.0', id: 1, method: 'getProgramAccounts', params: ['ProgramId', @options] }.to_json)
        .to_return(status: 200, body: @successful_response.to_json, headers: { 'Content-Type' => 'application/json' })

      response = client.get_program_accounts('ProgramId')
      expect(response).to be_an(Array)
      expect(response.first).to have_key('pubkey')
      expect(response.first['account']).to have_key('lamports')
      expect(response.first['account']).to have_key('data')
    end

    it 'raises an error when the request fails' do
      stub_request(:post, url)
        .with(body: { jsonrpc: '2.0', id: 1, method: 'getProgramAccounts', params: ['ProgramId', @options] }.to_json)
        .to_return(status: 400, body: @failed_response.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { client.get_program_accounts('ProgramId') }.to raise_error(SolanaRuby::SolanaError, /Invalid params/)
    end

    it 'raises an error for invalid JSON response' do
      stub_request(:post, url)
        .with(body: { jsonrpc: '2.0', id: 1, method: 'getProgramAccounts', params: ['ProgramId', @options] }.to_json)
        .to_return(status: 200, body: 'invalid json', headers: { 'Content-Type' => 'application/json' })

      expect { client.get_program_accounts('ProgramId') }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response/)
    end

    it 'handles timeout errors gracefully' do
      stub_request(:post, url)
        .with(body: { jsonrpc: '2.0', id: 1, method: 'getProgramAccounts', params: ['ProgramId', @options] }.to_json)
        .to_timeout

      expect { client.get_program_accounts('ProgramId') }.to raise_error(SolanaRuby::SolanaError, /Request timed out/)
    end

    it 'handles connection errors gracefully' do
      stub_request(:post, url)
        .with(body: { jsonrpc: '2.0', id: 1, method: 'getProgramAccounts', params: ['ProgramId', @options] }.to_json)
        .to_raise(SocketError)

      expect { client.get_program_accounts('ProgramId') }.to raise_error(SolanaRuby::SolanaError, /Failed to connect to the server/)
    end
  end
end
