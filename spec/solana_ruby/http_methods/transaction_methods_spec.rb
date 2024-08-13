require 'webmock/rspec'

RSpec.describe SolanaRuby::HttpMethods::TransactionMethods do
  let(:url) { "https://api.devnet.solana.com" }
  let(:client) { SolanaRuby::HttpClient.new(url) }
  let(:signature) { "5V5Q4eecvP2DC6aqL5zBzcKM3TMwgx4nnmgGNeJtMwk2GYQdUHWuz2wUC5RLdXQRXs71xScS2qfF8eGQaV7pBAEE" }
  let(:status_response) do
    {
      "jsonrpc" => "2.0",
      "result" => {
        "value" => [
          {
            "confirmationStatus" => "finalized",
            "err" => nil
          }
        ]
      },
      "id" => 1
    }.to_json
  end
  

  describe '#confirm_transaction' do
    context 'when the transaction is successfully confirmed' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: "2.0",
              id: 1,
              method: "getSignatureStatuses",
              params: [[signature], { "searchTransactionHistory" => true }]
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
          "jsonrpc" => "2.0",
          "error" => {
            "code" => -32600,
            "message" => "Invalid request"
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
              method: "getSignatureStatuses",
              params: [[signature], { "searchTransactionHistory" => true }]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: error_response, headers: {})
      end

      it 'handles the error and raises an appropriate exception' do
        expect {
          client.confirm_transaction(signature)
        }.to raise_error(RuntimeError, /An unexpected error occurred/)
      end
    end
  end
end
