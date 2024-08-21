# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::BlockMethods do
   
  describe '#get_blocks' do
    describe 'when there are blocks available' do
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

    describe 'when there are blocks available' do
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
    let(:rpc_url) { 'https://api.devnet.solana.com' }
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
        .with(body: hash_including(method: 'getBlock', params: [203343, { maxSupportedTransactionVersion: 0 }]))
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the block info of the given slot' do
      response = client.get_block(203343, { maxSupportedTransactionVersion: 0 })
      expect(response['blockHeight']).to eq(203340)
    end
  end

  describe '#get_block_production' do
    let(:url) { "https://api.devnet.solana.com" }
    let(:client) { SolanaRuby::HttpClient.new(url) }
    let(:response_body) do
      { context:
        { apiVersion: "2.0.5",
          slot: 123456789
        },
        value:
        {
          byIdentity: {
            "88B9r8s7adZZirAxGNQfvT2Zy7vwZtfCATaX27ZLP7Y1": [24, 18],
            "97YUjL2EK42M6jG5VA4fKuVxGXDfxsC5Zawd9haLQJGk": [3128, 3128],
            "BrX9Z85BbmXYMjvvuAWU8imwsAqutVQiDg9uNfTGkzrJ": [3080, 3080],
            "Cw6X5R68muAyGRCb7W8ZSP2YbaRjwMs1t5sBEPkhdwbM":[2936, 2908],
            "HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr": [320, 0],
            "dv1ZAGvdsz5hHLwWXsVnM94hWf1pjbKVau1QVkaMJ92": [57960, 57951],
            "dv2eQHeP4RFrJZ6UeiZWoc3XTtmtZCUKxxCApCDcRNV": [58088, 58087],
            "dv3qDFk1DTF36Z62bNvrCXe9sKATA6xvVy6A798xxAS": [57516, 57513],
            "dv4ACNkpYPcE3aKmYDqZm9G5EB3J4MRoeE7WNDRBVJB": [58468, 58463]},
            range: {
              firstSlot: 123456789, lastSlot: 123456789
            }
          }
        }.to_json
    end

    before do
      stub_request(:post, url)
        .with(body: hash_including(method: 'getBlockProduction'))
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the block production info' do
      response = client.get_block_production()
      expect(response['context']['apiVersion']).to eq('2.0.5')
      expect(response['context']['slot']).to eq(123456789)
    end
  end

  describe '#get_block_time' do
    let(:url) { "https://api.devnet.solana.com" }
    let(:client) { SolanaRuby::HttpClient.new(url) }
    let(:response_body) do
      { jsonrpc: '2.0', result: 1724232540, id: 1 }.to_json
    end

    before do
      stub_request(:post, url)
        .with(body: hash_including(method: 'getBlockTime', params: [320356594]))
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the block production info' do
      response = client.get_block_time(320356594)
      expect(response).to eq(1724232540)
    end
  end

  describe '#get_block_signatures#get_confirmed_block_signatures' do
    let(:url) { "https://api.devnet.solana.com" }
    let(:client) { SolanaRuby::HttpClient.new(url) }
    let(:block_slot) { 123456789 }

    context 'when the request is successful' do
      let(:block_data) do
        {
          "blockTime" => 1_620_979_841,
          "blockHeight" => 768_125,
          "blockhash" => "5KmMSW8gsH...XZ",
          "previousBlockhash" => "5KMkTLn...",
          "parentSlot" => 768_124,
          "transactions" => [
            { "transaction" => { "signatures" => ["5KmMSW8gsH", "6KmTTLj2kF"] }, "meta" => {} },
            { "transaction" => { "signatures" => ["9PmMSxk2sw"] }, "meta" => {} }
          ]
        }
      end

      let(:response_body) do
        {
          'jsonrpc' => '2.0',
          'result' => block_data,
          'id' => 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: "2.0",
              id: 1,
              method: "getBlock",
              params: [block_slot, { maxSupportedTransactionVersion: 0 }]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body, headers: {})
      end

      it 'returns the signatures from the block for the given slot' do
        signatures = client.get_block_signatures(block_slot)
        expected_signatures = {"blockHeight"=>768125, "blockTime"=>1620979841, "blockhash"=>"5KmMSW8gsH...XZ", "parentSlot"=>768124, "previousBlockhash"=>"5KMkTLn...", :signatures=>["5KmMSW8gsH", "6KmTTLj2kF"]}
        expect(signatures).to eq(expected_signatures)
      end
    end

    context 'when an error occurs' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: "2.0",
              id: 1,
              method: "getBlock",
              params: [block_slot, { maxSupportedTransactionVersion: 0 }]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: { 'error' => 'Internal Server Error' }.to_json)
      end

      it 'raises an error' do
        expect { client.get_block_signatures(block_slot) }.to raise_error(StandardError)
      end
    end
  end

  describe '#get_cluster_nodes' do
    let(:url) { "https://api.devnet.solana.com" }
    let(:client) { SolanaRuby::HttpClient.new(url) }

    context 'when the request is successful' do
      let(:cluster_nodes_data) do
        [
          {
            "pubkey" => "11111111111111111111111111111111",
            "gossip" => "127.0.0.1:8001",
            "tpu" => "127.0.0.1:8002",
            "rpc" => "127.0.0.1:8003",
            "version" => "1.7.10"
          },
          {
            "pubkey" => "22222222222222222222222222222222",
            "gossip" => "127.0.0.2:8001",
            "tpu" => "127.0.0.2:8002",
            "rpc" => "127.0.0.2:8003",
            "version" => "1.7.11"
          }
        ]
      end

      let(:response_body) do
        {
          'jsonrpc' => '2.0',
          'result' => cluster_nodes_data,
          'id' => 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: "2.0",
              id: 1,
              method: "getClusterNodes",
              params: []
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body, headers: {})
      end

      it 'returns the cluster nodes data' do
        nodes = client.get_cluster_nodes
        expect(nodes).to be_an(Array)
        expect(nodes.size).to eq(2)

        first_node = nodes.first
        expect(first_node['pubkey']).to eq('11111111111111111111111111111111')
        expect(first_node['gossip']).to eq('127.0.0.1:8001')
        expect(first_node['version']).to eq('1.7.10')
      end
    end

    context 'when an error occurs' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: "2.0",
              id: 1,
              method: "getClusterNodes",
              params: []
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: { 'error' => 'Internal Server Error' }.to_json)
      end

      it 'raises an error' do
        expect { client.get_cluster_nodes }.to raise_error(StandardError)
      end
    end
  end
end
