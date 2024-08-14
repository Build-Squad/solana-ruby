# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::BlockMethods do
   
  describe '#get_blocks' do
    describe 'when there are blocks available'
      let(:url) { "https://api.mannet-beta.solana.com" }
      let(:client) { SolanaRuby::HttpClient.new(url) }
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result: [39334, 39335, 39336, 39337, 39338, 39339],
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(body: hash_including(method: 'getBlocks', params: [39334, 39339]))
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the available blocks between the given interval' do
        response = client.get_blocks(39334, 39339)
        expect(response).to eq([39334, 39335, 39336, 39337, 39338, 39339])
      end
    end

    describe 'when there are blocks available'
      let(:url) { "https://api.devnet.solana.com" }
      let(:client) { SolanaRuby::HttpClient.new(url) }
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result: [],
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(body: hash_including(method: 'getBlocks', params: [39334, 39339]))
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the empty blocks between the given interval' do
        response = client.get_blocks(39334, 39339)
        expect(response).to eq([])
      end
    end
  end

  describe '#get_block' do
    let(:current_slot) { '39334' }
    let(:rpc_url) { 'http://localhost:8899' }
    let(:client) { SolanaRuby::HttpClient.new(rpc_url) }
    let(:response_body) do
     { "jsonrpc"=>"2.0",
       "result"=>{
          "blockHeight"=>203340,
         "blockTime"=>1721417102,
         "blockhash"=>"Cy4C5qMUwXZWTaxjKq3gvRd9oysF3wjQ99nsWxEFiDJL",
         "parentSlot"=>203342,
         "previousBlockhash"=>"CbqJ3eTZKUkF63bfUjNpsk9KHwtHvAQwDqbUBhWNJeT2",
         "rewards"=>[{"commission"=>nil, "lamports"=>5000, "postBalance"=>498983597500, "pubkey"=>"E3kZahegkznzg1Taukg3jk9yekZxMfdgcDxjkpMT8T6P", "rewardType"=>"Fee"}],
         "transactions"=>
          [{"meta"=>
             {"computeUnitsConsumed"=>2100,
              "err"=>nil,
              "fee"=>10000,
              "innerInstructions"=>[],
              "loadedAddresses"=>{"readonly"=>[], "writable"=>[]},
              "logMessages"=>["Program Vote111111111111111111111111111111111111111 invoke [1]", "Program Vote111111111111111111111111111111111111111 success"],
              "postBalances"=>[498983592500, 1000000000000000, 1],
              "postTokenBalances"=>[],
              "preBalances"=>[498983602500, 1000000000000000, 1],
              "preTokenBalances"=>[],
              "rewards"=>[],
              "status"=>{"Ok"=>nil}},
            "transaction"=>
             {"message"=>
               {"accountKeys"=>["E3kZahegkznzg1Taukg3jk9yekZxMfdgcDxjkpMT8T6P", "6rfWCFsi6Hs2Hk2nqMpy6hkYR1nRDE8YyxA5EHCmQG1n", "Vote111111111111111111111111111111111111111"],
                "header"=>{"numReadonlySignedAccounts"=>0, "numReadonlyUnsignedAccounts"=>1, "numRequiredSignatures"=>2},
                "instructions"=>
                 [{"accounts"=>[1, 1],
                   "data"=>
                    "Fk63PULYJTz4M1CDX6YmEHo6cQyD69zrdBggJw1sF6LbFC5QhNBjtpSmeEZxM2UFFu4Li6XVqqRnkEHprFXQsE8Cyf87Lz9rcg99jPnZrBLqD4zJPJmuUj8Ggr4nxMBJcNQuERTW1Ldsxh6oie4ZWpCFv6XqhH",
                   "programIdIndex"=>2,
                   "stackHeight"=>nil}],
                "recentBlockhash"=>"CbqJ3eTZKUkF63bfUjNpsk9KHwtHvAQwDqbUBhWNJeT2"},
              "signatures"=>
               ["4LoYJrDY2nP2GRqcSyPP6dyDfgwaNfhNfLW2ktiPtJpdMMQuHkN7cWbFWBUUCmaFa8RdiNJktgjqHiv3u9mNDvyo",
                "ELtdYzE7FPSyx4XmBYwC7LBvqtcou2LiYEe88jc4y7umeM8pGV8GUX24R8aSW6giqSEEsDKvW9TZL1yeXZMdisM"]}}]},
       "id"=>1
      }.to_json
    end

    before do
      stub_request(:post, rpc_url)
        .with(body: hash_including(method: 'getBlock', params: [203343]))
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the available blocks between the given interval' do
      response = client.get_block(203343)
      expect(response['blockHeight']).to eq(203340)
    end
  end
end
