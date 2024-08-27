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

  describe '#get_multiple_account_info' do
    let(:pubkeys) { ['ArBN2sDgpqjWEmr2Vk5WUHTC3SmusWYzMCTaA9rZ6itT', 'Ap4BqwYoXUD6JpjyPAiXX3JFX2FtBVBkpPFJGKQAyNX5'] }
    let(:options) { { encoding: 'base58' } }
    let(:valid_response) do
      {
        "jsonrpc" => "2.0",
        "result" => {
          "context" => { "slot" => 100 },
          "value" => [
            {
              "pubkey" => pubkeys[0],
              "account" => {
                "data" => {
                  "parsed" => {
                    "info" => { "tokenAmount" => { "amount" => "5000" } },
                    "type" => "account"
                  },
                  "lamports" => 2039280,
                  "owner" => "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                  "rentEpoch" => 234
                }
              }
            },
            {
              "pubkey" => pubkeys[1],
              "account" => {
                "data" => {
                  "parsed" => {
                    "info" => { "tokenAmount" => { "amount" => "10000" } },
                    "type" => "account"
                  },
                  "lamports" => 3058290,
                  "owner" => "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                  "rentEpoch" => 234
                }
              }
            }
          ]
        },
        "id" => 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: "2.0",
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

    context 'when an error occurs' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: "2.0",
              id: 1,
              method: 'getMultipleAccounts',
              params: [pubkeys, options]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: { error: { message: 'Internal server error' } }.to_json)
      end

      it 'raises an error' do
        expect { client.get_multiple_account_info(pubkeys, options) }
          .to raise_error(RuntimeError, "An unexpected error occurred: HTTP Error: 500 -")
      end
    end
  end
end
