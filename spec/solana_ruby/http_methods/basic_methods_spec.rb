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

      it 'raises a SolanaError with the error message' do
        expect { client.get_balance(invalid_pubkey) }.to raise_error(SolanaRuby::SolanaError, 'An unexpected error occurred: API Error: -32602 - Invalid params: Invalid')
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

      it 'raises a SolanaError with the wrongsize error message' do
        expect { client.get_balance(invalid_pubkey) }.to raise_error(SolanaRuby::SolanaError, 'An unexpected error occurred: API Error: -32602 - Invalid params: WrongSize')
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

  describe '#get_leader_schedule' do
    let(:request_body) do
      {
        jsonrpc: '2.0',
        id: 1,
        method: 'getLeaderSchedule',
        params: [{ epoch: nil }]
      }
    end

    context 'when the request is successful' do
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result: {
            '1': ['validator1', 'validator2'],
            '2': ['validator3', 'validator4']
          },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: request_body.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body, headers: {})
      end

      it 'returns the leader schedule' do
        result = client.get_leader_schedule
        expect(result).to eq({
          "1" => ["validator1", "validator2"],
          "2" => ["validator3", "validator4"]
        })
      end
    end

    context 'when the API returns an error' do
      let(:error_response_body) do
        {
          jsonrpc: '2.0',
          error: { code: -32600, message: 'Invalid Request' },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: request_body.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: error_response_body, headers: {})
      end

      it 'raises a SolanaError with the correct message' do
        expect { client.get_leader_schedule }.to raise_error(SolanaRuby::SolanaError, 'An unexpected error occurred: API Error: -32600 - Invalid Request')
      end
    end

    context 'when there is a network error' do
      before do
        stub_request(:post, url)
          .to_raise(SocketError.new('Failed to connect'))
      end

      it 'raises a SolanaError with a connection failure message' do
        expect { client.get_leader_schedule }.to raise_error(SolanaRuby::SolanaError, 'Failed to connect to the server')
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .with(
            body: request_body.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises a SolanaError with an invalid JSON message' do
        expect { client.get_leader_schedule }.to raise_error(SolanaRuby::SolanaError, 'An unexpected error occurred: Invalid JSON response: Invalid JSON')
      end
    end
  end

  describe '#get_minimum_balance_for_rent_exemption' do
    let(:data_size) { 1234 }
    let(:options) { { commitment: 'finalized' } }
    let(:request_body) do
      {
        jsonrpc: '2.0',
        id: 1,
        method: 'getMinimumBalanceForRentExemption',
        params: [data_size, options]
      }
    end

    context 'when the request is successful' do
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result: 2039280,
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: request_body.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body, headers: {})
      end

      it 'returns the minimum balance for rent exemption' do
        result = client.get_minimum_balance_for_rent_exemption(data_size)
        expect(result).to eq(2039280)
      end
    end

    context 'when the API returns an error' do
      let(:error_response_body) do
        {
          jsonrpc: '2.0',
          error: { code: -32600, message: 'Invalid Request' },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: request_body.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: error_response_body, headers: {})
      end

      it 'raises a SolanaError with the correct message' do
        expect { client.get_minimum_balance_for_rent_exemption(data_size) }
          .to raise_error(SolanaRuby::SolanaError, 'An unexpected error occurred: API Error: -32600 - Invalid Request')
      end
    end

    context 'when there is a network error' do
      before do
        stub_request(:post, url)
          .to_raise(SocketError.new('Failed to connect'))
      end

      it 'raises a SolanaError with a connection failure message' do
        expect { client.get_minimum_balance_for_rent_exemption(data_size) }
          .to raise_error(SolanaRuby::SolanaError, 'Failed to connect to the server')
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .with(
            body: request_body.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises a SolanaError with an invalid JSON message' do
        expect { client.get_minimum_balance_for_rent_exemption(data_size) }
          .to raise_error(SolanaRuby::SolanaError, 'An unexpected error occurred: Invalid JSON response: Invalid JSON')
      end
    end
  end

  describe '#get_stake_activation' do
    let(:account_pubkey) { 'Pubkey1234567890abcdef' }
    let(:options) { { commitment: 'finalized', epoch: nil } }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: {
          activation: 1000,
          deactivation: 2000,
          status: 'active'
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
            method: 'getStakeActivation',
            params: [account_pubkey, options]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the stake activation information' do
      result = client.get_stake_activation(account_pubkey, options)
      expect(result).to eq({
        'activation' => 1000,
        'deactivation' => 2000,
        'status' => 'active'
      })
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(status: 500, body: { jsonrpc: '2.0', error: { code: -32000, message: 'Server error' } }.to_json, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_stake_activation(account_pubkey, options) }.to raise_error(SolanaRuby::SolanaError, /HTTP Error: 500 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_stake_activation(account_pubkey, options) }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end
  end

  describe '#get_supply' do
    let(:options) { { commitment: 'finalized' } }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: {
          total: 1234567890,
          circulating: 1234560000
        },
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: "2.0",
            id: 1,
            method: 'getSupply',
            params: [options]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the supply information' do
      result = client.get_supply()
      expect(result).to eq({
        'total' => 1234567890,
        'circulating' => 1234560000
      })
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: { jsonrpc: '2.0', error: { code: -32000, message: 'Server error' } }.to_json, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_supply() }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: "Invalid JSON", headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_supply() }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end
  end

  describe '#get_version' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: {
          'solana-core': '1.9.10',
          version: '1.9.10'
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
            method: 'getVersion',
            params: []
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the version information' do
      result = client.get_version
      expect(result).to eq({
        'solana-core' => '1.9.10',
        'version' => '1.9.10'
      })
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: { jsonrpc: '2.0', error: { code: -32000, message: 'Server error' } }.to_json, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_version }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_version }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end
  end

  describe '#get_total_supply' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: {
          value: {
            total: 1_000_000_000
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
            method: 'getSupply',
            params: [{ commitment: 'finalized' }]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the total supply' do
      result = client.get_total_supply
      expect(result).to eq(1_000_000_000)
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: {
              jsonrpc: '2.0',
              error: { code: -32000, message: 'Server error' }
            }.to_json,
            headers: {}
          )
      end

      it 'raises an API error' do
        expect { client.get_total_supply }.to raise_error(
          SolanaRuby::SolanaError,
          /API Error: -32000 - Server error/
        )
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: 'Invalid JSON',
            headers: {}
          )
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_total_supply }.to raise_error(
          SolanaRuby::SolanaError,
          /Invalid JSON response: Invalid JSON/
        )
      end
    end
  end

  describe '#get_health' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: 'ok',  # Example response for a healthy state
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getHealth',
            params: []
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the health status' do
      result = client.get_health
      expect(result).to eq('ok')  # Expecting 'ok' as a sample healthy response
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: {
              jsonrpc: '2.0',
              error: { code: -32000, message: 'Server error' }
            }.to_json,
            headers: {}
          )
      end

      it 'raises an API error' do
        expect { client.get_health }.to raise_error(
          SolanaRuby::SolanaError,
          /API Error: -32000 - Server error/
        )
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: 'Invalid JSON',
            headers: {}
          )
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_health }.to raise_error(
          SolanaRuby::SolanaError,
          /Invalid JSON response: Invalid JSON/
        )
      end
    end
  end

  describe '#get_identity' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: 'Solana Identity',  # Example identity response
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getIdentity',
            params: []
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the identity information' do
      result = client.get_identity
      expect(result).to eq('Solana Identity')  # Expecting a sample identity response
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: {
              jsonrpc: '2.0',
              error: { code: -32000, message: 'Server error' }
            }.to_json,
            headers: {}
          )
      end

      it 'raises an API error' do
        expect { client.get_identity }.to raise_error(
          SolanaRuby::SolanaError,
          /API Error: -32000 - Server error/
        )
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: 'Invalid JSON',
            headers: {}
          )
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_identity }.to raise_error(
          SolanaRuby::SolanaError,
          /Invalid JSON response: Invalid JSON/
        )
      end
    end
  end

  describe '#get_recent_performance_samples' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: [
          { sample_1: 'data_1' }, 
          { sample_2: 'data_2' }
        ],
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getRecentPerformanceSamples',
            params: [10]  # Default limit
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns recent performance samples' do
      result = client.get_recent_performance_samples
      expect(result).to eq([
        { 'sample_1' => 'data_1' }, 
        { 'sample_2' => 'data_2' }
      ])
    end

    context 'when a limit is specified' do
      let(:response_body_with_limit) do
        {
          jsonrpc: '2.0',
          result: [
            { 'sample_1' => 'data_1' }
          ],
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'getRecentPerformanceSamples',
              params: [5]  # Custom limit
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body_with_limit, headers: {})
      end

      it 'returns recent performance samples with the specified limit' do
        result = client.get_recent_performance_samples(5)
        expect(result).to eq([{ 'sample_1' => 'data_1' }])
      end
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: {
              jsonrpc: '2.0',
              error: { code: -32000, message: 'Server error' }
            }.to_json,
            headers: {}
          )
      end

      it 'raises an API error' do
        expect { client.get_recent_performance_samples }.to raise_error(
          SolanaRuby::SolanaError,
          /API Error: -32000 - Server error/
        )
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: 'Invalid JSON',
            headers: {}
          )
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_recent_performance_samples }.to raise_error(
          SolanaRuby::SolanaError,
          /Invalid JSON response: Invalid JSON/
        )
      end
    end
  end

  describe '#get_recent_prioritization_fees' do
    let(:addresses) { ['address1', 'address2'] }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: [
          { 'address1' => 'fee1' }, 
          { 'address2' => 'fee2' }
        ],
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getRecentPrioritizationFees',
            params: [addresses]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns recent prioritization fees' do
      result = client.get_recent_prioritization_fees(addresses)
      expect(result).to eq([
        { 'address1' => 'fee1' }, 
        { 'address2' => 'fee2' }
      ])
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: {
              jsonrpc: '2.0',
              error: { code: -32000, message: 'Server error' }
            }.to_json,
            headers: {}
          )
      end

      it 'raises an API error' do
        expect { client.get_recent_prioritization_fees(addresses) }.to raise_error(
          SolanaRuby::SolanaError,
          /API Error: -32000 - Server error/
        )
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: 'Invalid JSON',
            headers: {}
          )
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_recent_prioritization_fees(addresses) }.to raise_error(
          SolanaRuby::SolanaError,
          /Invalid JSON response: Invalid JSON/
        )
      end
    end
  end
end
