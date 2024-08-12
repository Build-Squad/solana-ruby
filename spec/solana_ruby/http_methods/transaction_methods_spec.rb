# frozen_string_literal: true
require 'base64'

RSpec.describe SolanaRuby::HttpClient do
  before do
    @client = SolanaRuby::HttpClient.new("http://localhost:8899")
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  describe '#send_transaction' do
    let(:signed_transaction) { "4hXTCkRzt9WyecNzV1XPgCDfGAZzQKNxLXgynz5QDuWWPSAZBZSHptvWRL3BjCvzUXRdKvHL2b7yGrRQcWyaqsaBCncVG7BFggS8w9snUts67BSh3EqKpXLUm5UMHfD7ZBe9GhARjbNQMLJ1QD3Spr6oMTBU6EhdB4RD8CP2xUxr2u3d6fos36PD98XS6oX8TQjLpsMwncs5DAMiD4nNnR8NBfyghGCWvCVifVwvA8B8TJxE1aiyiv2L429BCWfyzAme5sZW8rDb14NeCQHhZbtNqfXhcp2tAnaAT" }

    context 'when the transaction is successful' do
      it 'returns the transaction signature' do
        stub_request(:post, "http://localhost:8899")
          .with(
            body: {
              jsonrpc: "2.0",
              id: a_string_matching(/^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/),
              method: "sendTransaction",
              params: [signed_transaction]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(
            status: 200,
            body: {
              result: "transaction_signature"
            }.to_json
          )

        result = @client.send_transaction(signed_transaction)
        expect(result).to eq("transaction_signature")
      end
    end
  end
end
