# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::BasicMethods do
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


  describe '#get_slot' do
    let(:response_body) do
      { jsonrpc: '2.0', result: 12345, id: 1}.to_json
    end

    before do
      stub_request(:post, url)
        .with(body: hash_including(method: 'getSlot'))
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the current and available slot' do
      response = client.get_slot()
      expect(response).to eq(12345)
    end
  end

  describe '#get_epoch_info' do
    before do
      stub_request(:post, url)
        .with(
          body: { 
            jsonrpc: '2.0', 
            id: 1, 
            method: 'getEpochInfo', 
            params: [{ 'commitment' => 'finalized' }]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: {
          jsonrpc: "2.0",
          result: {
            epoch: 205,
            slotIndex: 12345,
            slotsInEpoch: 432000,
            absoluteSlot: 885431,
            blockHeight: 12345678,
            transactionCount: 2345678
          },
          id: 1
        }.to_json)
    end

    it 'retrieves the current epoch info similarly to Web3.js' do
      response = client.get_epoch_info
      expect(response['epoch']).to eq(205)
      expect(response['slotIndex']).to eq(12345)
    end
  end

  describe '#get_epoch_schedule' do
    before do
      stub_request(:post, url)
        .with(
          body: { jsonrpc: '2.0', id: 1, method: 'getEpochSchedule', params: [] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            result: {
              firstNormalEpoch: 8,
              firstNormalSlot: 8160,
              leaderScheduleSlotOffset: 8192,
              slotsPerEpoch: 8192,
              warmup: true
            },
            id: 1
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the epoch schedule data' do
      result = client.get_epoch_schedule
      expect(result).to eq({
        "firstNormalEpoch"=> 8,
        "firstNormalSlot"=> 8160,
        "leaderScheduleSlotOffset"=> 8192,
        "slotsPerEpoch"=> 8192,
        "warmup"=> true
      })
    end

    context 'handles errors gracefully' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: "2.0",
              id: 1,
              method: "getEpochSchedule",
              params: []
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: { error: 'Internal Server Error' }.to_json)
      end

      it 'raises an error' do
        expect { client.get_epoch_schedule() }.to raise_error(StandardError)
      end
    end
  end

  describe '#get_genesis_hash' do
    before do
      stub_request(:post, url)
        .with(
          body: { jsonrpc: '2.0', id: 1, method: 'getGenesisHash', params: [] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: { result: '2T4oJrW8b5u8qf8BHEj9fp8cV9Tf5XEB5TtZ2xqMiMJo' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the genesis hash' do
      result = client.get_genesis_hash
      expect(result).to eq('2T4oJrW8b5u8qf8BHEj9fp8cV9Tf5XEB5TtZ2xqMiMJo')
    end

    context 'handles errors gracefully' do
      before do
        stub_request(:post, url)
          .with(
            body:{ jsonrpc: '2.0', id: 1, method: 'getGenesisHash', params: [] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: { error: 'Internal Server Error' }.to_json)
      end

      it 'raises an error' do
        expect { client.get_genesis_hash() }.to raise_error(StandardError)
      end
    end
  end

  describe '#get_inflation_governor' do
    before do
      stub_request(:post, url)
        .with(
          body: { jsonrpc: '2.0', id: 1, method: 'getInflationGovernor', params: [] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            result: {
              foundation: 0.05,
              foundationTerm: 7,
              initial: 0.15,
              taper: 0.15,
              terminal: 0.015
            },
            id: 1
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the inflation governor info' do
      result = client.get_inflation_governor
      expect(result['foundation']).to eq(0.05)
      expect(result['initial']).to eq(0.15)
      expect(result['terminal']).to eq(0.015)
    end
  end

  describe '#get_inflation_rate' do
    before do
      stub_request(:post, url)
        .with(
          body: { jsonrpc: '2.0', id: 1, method: 'getInflationRate', params: [] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: { result: { epoch: 0.02, foundation: 0.01, total: 0.15, validator: 0.01 } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

  
    it 'returns the inflation rate data' do
      result = client.get_inflation_rate
      expect(result).to eq({
        "epoch"=> 0.02,
        "foundation"=> 0.01,
        "total"=> 0.15,
        "validator"=> 0.01
      })
    end
  end

  describe '#get_inflation_reward' do
    let(:addresses) { ['6dmNQ5jwLeLk5REvio1JcMshcbvkYMwy26sJ8pbkvStu', 'BGsqMegLpV6n6Ve146sSX2dTjUMj3M92HnU8BbNRMhF2'] }
    before do
      stub_request(:post, url)
        .with(
          body: { jsonrpc: '2.0', id: 1, method: 'getInflationReward', params: [addresses, { epoch: 2 }] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            result: [
              {
                amount: 2500,
                effectiveSlot: 224,
                epoch: 2,
                postBalance: 499999442500
              },
              nil
            ],
            id: 1
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end
 
    it 'returns the inflation reward data' do
      response = client.get_inflation_reward(addresses, { epoch: 2 })
      expect(response['result'][0]['amount']).to eq(2500)
      expect(response['result'][0]['effectiveSlot']).to eq(224)
    end
  end
end
