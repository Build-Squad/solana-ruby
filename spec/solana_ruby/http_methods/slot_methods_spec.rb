# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::SlotMethods do
  let(:url) { 'https://api.devnet.solana.com' }
  let(:client) { SolanaRuby::HttpClient.new(url) }
  
  describe '#get_slot' do
    let(:valid_response_body) do
      {
        jsonrpc: '2.0',
        result: 12345678,
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getSlot',
            params: []
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: valid_response_body, headers: {})
    end

    it 'returns the current slot number' do
      result = client.get_slot
      expect(result).to eq(12_345_678)
    end

    context 'when there is an API error' do
      let(:error_response_body) do
        {
          jsonrpc: '2.0',
          error: { code: -32000, message: 'Server error' },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'getSlot',
              params: []
            }.to_json
          )
          .to_return(status: 200, body: error_response_body, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_slot }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_slot }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end
  end

  describe '#get_slot_leader' do
    let(:options) { { commitment: 'finalized' } }
    let(:valid_response_body) do
      {
        jsonrpc: '2.0',
        result: 'D45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww5',
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getSlotLeader',
            params: [options]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: valid_response_body, headers: {})
    end

    it 'returns the current slot leader' do
      result = client.get_slot_leader(options)
      expect(result).to eq('D45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww5')
    end

    context 'when there is an API error' do
      let(:error_response_body) do
        {
          jsonrpc: '2.0',
          error: { code: -32000, message: 'Server error' },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'getSlotLeader',
              params: [options]
            }.to_json
          )
          .to_return(status: 200, body: error_response_body, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_slot_leader(options) }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_slot_leader(options) }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end
  end

  describe '#get_slot_leaders' do
    let(:start_slot) { 100 }
    let(:limit) { 5 }
    let(:valid_response_body) do
      {
        jsonrpc: '2.0',
        result: [
          'D45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww5',
          'G45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww6',
          'E45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww7',
          'H45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww8',
          'J45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww9'
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
            method: 'getSlotLeaders',
            params: [start_slot, limit]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: valid_response_body, headers: {})
    end

    it 'returns a list of slot leaders' do
      result = client.get_slot_leaders(start_slot, limit)
      expect(result).to eq([
       'D45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww5',
        'G45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww6',
        'E45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww7',
        'H45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww8',
        'J45hTGZ3gpdjqVEyz5ChAwR9AbTvX53dKKmQ4qWSCww9'
      ])
    end

    context 'when there is an API error' do
      let(:error_response_body) do
        {
          jsonrpc: '2.0',
          error: { code: -32000, message: 'Server error' },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'getSlotLeaders',
              params: [start_slot, limit]
            }.to_json
          )
          .to_return(status: 200, body: error_response_body, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_slot_leaders(start_slot, limit) }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_slot_leaders(start_slot, limit) }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end
  end

  describe '#get_highest_snapshot_slot' do
    let(:valid_response_body) do
      {
        jsonrpc: '2.0',
        result: {
          full: 400000,
          incremental: 399900
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
            method: 'getHighestSnapshotSlot',
            params: []
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: valid_response_body, headers: {})
    end

    it 'returns the highest snapshot slot information' do
      result = client.get_highest_snapshot_slot
      expect(result).to eq({
        'full' => 400000,
        'incremental' => 399900
      })
    end

    context 'when there is an API error' do
      let(:error_response_body) do
        {
          jsonrpc: '2.0',
          error: { code: -32000, message: 'Server error' },
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'getHighestSnapshotSlot',
              params: []
            }.to_json
          )
          .to_return(status: 200, body: error_response_body, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_highest_snapshot_slot }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_highest_snapshot_slot }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end
  end

  describe '#get_minimum_ledger_slot' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: 123456,
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'minimumLedgerSlot',
            params: []
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the minimum ledger slot' do
      result = client.get_minimum_ledger_slot
      expect(result).to eq(123456)
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: { jsonrpc: '2.0', error: { code: -32000, message: 'Server error' } }.to_json, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_minimum_ledger_slot }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_minimum_ledger_slot }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end

    context 'when a Timeout::Error occurs' do
      before do
        allow(Net::HTTP).to receive(:new).and_raise(Timeout::Error)
      end

      it 'raises a timeout error' do
        expect { client.get_minimum_ledger_slot }.to raise_error(SolanaRuby::SolanaError, /Request timed out/)
      end
    end
  end

  describe '#get_max_retransmit_slot' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: 987654,
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getMaxRetransmitSlot',
            params: []
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the max retransmit slot' do
      result = client.get_max_retransmit_slot
      expect(result).to eq(987654)
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: { jsonrpc: '2.0', error: { code: -32000, message: 'Server error' } }.to_json, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_max_retransmit_slot }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_max_retransmit_slot }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end

    context 'when a Timeout::Error occurs' do
      before do
        allow(Net::HTTP).to receive(:new).and_raise(Timeout::Error)
      end

      it 'raises a timeout error' do
        expect { client.get_max_retransmit_slot }.to raise_error(SolanaRuby::SolanaError, /Request timed out/)
      end
    end
  end

  describe '#get_max_shred_insert_slot' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: 12345678, # Example shred insert slot
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'getMaxShredInsertSlot',
            params: []
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the max shred insert slot' do
      result = client.get_max_shred_insert_slot
      expect(result).to eq(12345678)
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: { jsonrpc: '2.0', error: { code: -32000, message: 'Server error' } }.to_json, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_max_shred_insert_slot }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_max_shred_insert_slot }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end

    context 'when a Timeout::Error occurs' do
      before do
        allow(Net::HTTP).to receive(:new).and_raise(Timeout::Error)
      end

      it 'raises a timeout error' do
        expect { client.get_max_shred_insert_slot }.to raise_error(SolanaRuby::SolanaError, /Request timed out/)
      end
    end
  end
end
