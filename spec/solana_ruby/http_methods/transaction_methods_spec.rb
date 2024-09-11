# frozen_string_literal: true

RSpec.describe SolanaRuby::HttpMethods::TransactionMethods do
  let(:url) { "https://api.devnet.solana.com" }
  let(:client) { SolanaRuby::HttpClient.new(url) }
  let(:signature) { "5V5Q4eecvP2DC6aqL5zBzcKM3TMwgx4nnmgGNeJtMwk2GYQdUHWuz2wUC5RLdXQRXs71xScS2qfF8eGQaV7pBAEE" }
  let(:options) { { commitment: 'finalized' } }
  let(:status_response) do
    {
      jsonrpc: '2.0',
      result: {
        value: [
          {
            confirmationStatus: 'finalized',
            err: nil
          }
        ]
      },
      id: 1
    }.to_json
  end
  

  describe '#confirm_transaction' do
    context 'when the transaction is successfully confirmed' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'getSignatureStatuses',
              params: [[signature], { searchTransactionHistory: true }]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: status_response, headers: {})
      end

      it 'returns true when the transaction is confirmed' do
        result = client.confirm_transaction(signature)
        expect(result).to be(true)
      end
    end

    context 'when an error occurs during confirmation' do
      let(:error_response) do
        {
          jsonrpc: '2.0',
          error: {
            code: -32600,
            message: 'Invalid request'
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
              method: 'getSignatureStatuses',
              params: [[signature], { searchTransactionHistory: true }]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: error_response, headers: {})
      end

      it 'handles the error and raises an appropriate exception' do
        expect {
          client.confirm_transaction(signature)
        }.to raise_error(SolanaRuby::SolanaError, /An unexpected error occurred/)
      end
    end
  end

  describe '#get_transaction' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: {
          slot: 12345678,
          transaction: { signatures: [signature] },
          meta: { status: { Ok: nil } }
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
            method: 'getTransaction',
            params: [signature, options]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the transaction information' do
      result = client.get_transaction(signature, options)
      expect(result['slot']).to eq(12345678)
      expect(result['transaction']['signatures']).to eq([signature])
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: { jsonrpc: '2.0', error: { code: -32000, message: 'Server error' } }.to_json, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_transaction(signature, options) }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_transaction(signature, options) }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end

    context 'when a Timeout::Error occurs' do
      before do
        allow(Net::HTTP).to receive(:new).and_raise(Timeout::Error)
      end

      it 'raises a timeout error' do
        expect { client.get_transaction(signature, options) }.to raise_error(SolanaRuby::SolanaError, /Request timed out/)
      end
    end
  end

  describe '#send_transaction' do
    let(:signed_transaction) { '5fHZ...example' }
    let(:options) { {} }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        result: '5ShB...exampleTxHash',
        id: 1
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            id: 1,
            method: 'sendTransaction',
            params: [signed_transaction, options]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the transaction hash when successful' do
      result = client.send_transaction(signed_transaction, options)
      expect(result).to eq('5ShB...exampleTxHash')
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: { jsonrpc: '2.0', error: { code: -32000, message: 'Server error' } }.to_json, headers: {})
      end

      it 'raises an API error' do
        expect { client.send_transaction(signed_transaction, options) }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.send_transaction(signed_transaction, options) }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end

    context 'when a Timeout::Error occurs' do
      before do
        allow(Net::HTTP).to receive(:new).and_raise(Timeout::Error)
      end

      it 'raises a timeout error' do
        expect { client.send_transaction(signed_transaction, options) }.to raise_error(SolanaRuby::SolanaError, /Request timed out/)
      end
    end
  end
end
