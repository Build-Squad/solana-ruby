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

  describe '#get_transaction_count' do
    let(:options) { { commitment: 'finalized' } }
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
            method: 'getTransactionCount',
            params: [options]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'returns the transaction count' do
      result = client.get_transaction_count
      expect(result).to eq(123456)
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: { jsonrpc: '2.0', error: { code: -32000, message: 'Server error' } }.to_json, headers: {})
      end

      it 'raises an API error' do
        expect { client.get_transaction_count }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_transaction_count }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end
  end

  describe '#request_airdrop' do
    let(:pubkey) { 'ExamplePublicKey123' }
    let(:lamports) { 1_000_000 }
    let(:options) { { commitment: 'finalized' } }

    context 'when the request is successful' do
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result: 'exampleTxSignature1234567890',
          id: 1
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'requestAirdrop',
              params: [pubkey, lamports, options]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body, headers: {})
      end

      it 'returns the transaction signature' do
        result = client.request_airdrop(pubkey, lamports, options)
        expect(result).to eq('exampleTxSignature1234567890')
      end
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'requestAirdrop',
              params: [pubkey, lamports, options]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: {
            jsonrpc: '2.0',
            error: { code: -32000, message: 'Server error' },
            id: 1
          }.to_json)
      end

      it 'raises an API error' do
        expect { client.request_airdrop(pubkey, lamports, options) }
          .to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.request_airdrop(pubkey, lamports, options) }
          .to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end

    context 'when there is a Timeout::Error' do
      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(Timeout::Error)
      end

      it 'raises a timeout error' do
        expect { client.request_airdrop(pubkey, lamports, options) }
          .to raise_error(SolanaRuby::SolanaError, /Request timed out/)
      end
    end

    context 'when there is a SocketError' do
      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(SocketError)
      end

      it 'raises a connection error' do
        expect { client.request_airdrop(pubkey, lamports, options) }
          .to raise_error(SolanaRuby::SolanaError, /Failed to connect to the server/)
      end
    end
  end

  describe '#simulate_transaction' do
    let(:transaction) { 'base64EncodedTransactionData' }
    let(:options) { { sigVerify: true, commitment: 'finalized' } }
    context 'when the request is successful' do
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result: {
            context: { slot: 12345 },
            value: { logs: ['log message 1', 'log message 2'] }
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
              method: 'simulateTransaction',
              params: [transaction, options]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body, headers: {})
      end

      it 'returns the simulation result' do
        result = client.simulate_transaction(transaction, options)
        expect(result['value']['logs']).to eq(['log message 1', 'log message 2'])
        expect(result['context']['slot']).to eq(12345)
      end
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'simulateTransaction',
              params: [transaction, options]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: {
            jsonrpc: '2.0',
            error: { code: -32000, message: 'Server error' },
            id: 1
          }.to_json)
      end

      it 'raises an API error' do
        expect { client.simulate_transaction(transaction, options) }
          .to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.simulate_transaction(transaction, options) }
          .to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end

    context 'when there is a Timeout::Error' do
      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(Timeout::Error)
      end

      it 'raises a timeout error' do
        expect { client.simulate_transaction(transaction, options) }
          .to raise_error(SolanaRuby::SolanaError, /Request timed out/)
      end
    end

    context 'when there is a SocketError' do
      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(SocketError)
      end

      it 'raises a connection error' do
        expect { client.simulate_transaction(transaction, options) }
          .to raise_error(SolanaRuby::SolanaError, /Failed to connect to the server/)
      end
    end
  end

  describe '#send_encoded_transaction' do
    let(:encoded_transaction) { 'base64EncodedTransactionData' }
    let(:options) { { skipPreflight: false, commitment: 'finalized' } }

    context 'when the request is successful' do
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result: 'transactionSignature',
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
              params: [encoded_transaction, options]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body, headers: {})
      end

      it 'returns the transaction signature' do
        result = client.send_encoded_transaction(encoded_transaction, options)
        expect(result).to eq('transactionSignature')
      end
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              id: 1,
              method: 'sendTransaction',
              params: [encoded_transaction, options]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: {
            jsonrpc: '2.0',
            error: { code: -32000, message: 'Transaction failed' },
            id: 1
          }.to_json)
      end

      it 'raises an API error' do
        expect { client.send_encoded_transaction(encoded_transaction, options) }
          .to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Transaction failed/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.send_encoded_transaction(encoded_transaction, options) }
          .to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end

    context 'when there is a Timeout::Error' do
      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(Timeout::Error)
      end

      it 'raises a timeout error' do
        expect { client.send_encoded_transaction(encoded_transaction, options) }
          .to raise_error(SolanaRuby::SolanaError, /Request timed out/)
      end
    end

    context 'when there is a SocketError' do
      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(SocketError)
      end

      it 'raises a connection error' do
        expect { client.send_encoded_transaction(encoded_transaction, options) }
          .to raise_error(SolanaRuby::SolanaError, /Failed to connect to the server/)
      end
    end
  end

  describe '#send_raw_transaction' do
    let(:raw_transaction) { 'hexEncodedRawTransactionData' }
    let(:base64_encoded_transaction) { Base64.encode64(raw_transaction) }
    let(:options) { { skipPreflight: false, commitment: 'finalized' } }
    
    context 'when the request is successful' do
      let(:response_body) do
        {
          jsonrpc: '2.0',
          result: 'transactionSignature',
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
              params: [base64_encoded_transaction, options]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: response_body, headers: {})
      end

      it 'returns the transaction signature' do
        result = client.send_raw_transaction(raw_transaction)
        expect(result).to eq('transactionSignature')
      end
    end

    context 'when there is an API error' do
      let(:error_body) do
        {
          jsonrpc: '2.0',
          error: { code: -32000, message: 'Transaction failed' },
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
              params: [base64_encoded_transaction, options]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: error_body, headers: {})
      end

      it 'raises an API error' do
        expect { client.send_raw_transaction(raw_transaction) }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Transaction failed/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        stub_request(:post, url)
          .to_return(status: 200, body: 'Invalid JSON', headers: {})
      end

      it 'raises an Invalid JSON response error' do
        expect { client.send_raw_transaction(raw_transaction) }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end

    context 'when there is a Timeout::Error' do
      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(Timeout::Error)
      end

      it 'raises a SolanaError for timeout' do
        expect { client.send_raw_transaction(raw_transaction) }.to raise_error(SolanaRuby::SolanaError, 'Request timed out')
      end
    end

    context 'when there is a SocketError' do
      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(SocketError)
      end

      it 'raises a SolanaError for socket error' do
        expect { client.send_raw_transaction(raw_transaction) }.to raise_error(SolanaRuby::SolanaError, 'Failed to connect to the server')
      end
    end
  end
  
  describe '#get_transactions' do
    let(:signatures) { ['signature1', 'signature2'] }
    let(:options) { { commitment: 'finalized' } }
    
    context 'when all requests are successful' do
      let(:responses) do
        [
          { 'transaction': 'data1' },
          { 'transaction': 'data2' }
        ]
      end
      
      before do
        signatures.each_with_index do |signature, index|
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
            .to_return(status: 200, body: { jsonrpc: '2.0', result: responses[index], id: 1 }.to_json, headers: {})
        end
      end

      it 'returns an array of transactions' do
        result = client.get_transactions(signatures)
        expect(result).to eq([{ 'transaction'=> 'data1' }, { 'transaction'=> 'data2' }])
      end
    end

    context 'when one of the requests fails with an API error' do
      before do
        signatures.each_with_index do |signature, index|
          if index == 0
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
              .to_return(status: 200, body: { jsonrpc: '2.0', error: { code: -32000, message: 'Server error' }, id: 1 }.to_json, headers: {})
          else
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
              .to_return(status: 200, body: { jsonrpc: '2.0', result: { 'transaction': 'data2' }, id: 1 }.to_json, headers: {})
          end
        end
      end

      it 'raises an API error' do
        expect { client.get_transactions(signatures) }.to raise_error(SolanaRuby::SolanaError, /API Error: -32000 - Server error/)
      end
    end

    context 'when the response is invalid JSON' do
      before do
        signatures.each do |signature|
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
            .to_return(status: 200, body: 'Invalid JSON', headers: {})
        end
      end

      it 'raises an Invalid JSON response error' do
        expect { client.get_transactions(signatures) }.to raise_error(SolanaRuby::SolanaError, /Invalid JSON response: Invalid JSON/)
      end
    end

    context 'when there is an HTTP error' do
      before do
        signatures.each do |signature|
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
            .to_return(status: 500, body: { error: { message: 'Internal Server Error' } }.to_json, headers: {})
        end
      end

      it 'raises an HTTP error' do
        expect { client.get_transactions(signatures) }.to raise_error(SolanaRuby::SolanaError, /HTTP Error: 500 - Internal Server Error/)
      end
    end

    context 'when there is a socket error' do
      before do
        signatures.each do |signature|
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
            .to_raise(SocketError)
        end
      end

      it 'raises a socket error' do
        expect { client.get_transactions(signatures) }.to raise_error(SolanaRuby::SolanaError, /Failed to connect to the server/)
      end
    end

    context 'when there is a timeout error' do
      before do
        signatures.each do |signature|
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
            .to_raise(Timeout::Error)
        end
      end

      it 'raises a timeout error' do
        expect { client.get_transactions(signatures) }.to raise_error(SolanaRuby::SolanaError, /Request timed out/)
      end
    end
  end
end
