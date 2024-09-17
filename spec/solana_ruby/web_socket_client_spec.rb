# spec/web_socket_client_spec.rb

require 'spec_helper'

RSpec.describe SolanaRuby::WebSocketClient do
  let(:url) { 'wss://api.devnet.solana.com' }
  let(:ws_instance) { double(WebSocket::Client::Simple) }
  let(:client) { SolanaRuby::WebSocketClient.new(url) }


  describe '#accountSubscribe' do
    let(:id) { '12356789' } # Simulate a generated request ID
    let(:subscription_id) { '58984940-3093-44a1-a0fd-13abaddf57c7' }
    let(:account_address) { '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g' }
    let(:params) { [account_address] }
    let(:response) do
      {
        'jsonrpc' => '2.0',
        'id' => subscription_id,
        'result' => { 'value' => 'account-data' }
      }.to_json
    end

    before do
      # Mock the WebSocket::Client::Simple.connect method to return the WebSocket instance double
      allow(WebSocket::Client::Simple).to receive(:connect).and_return(ws_instance)

      # Mock the send method on the WebSocket instance
      allow(ws_instance).to receive(:send)

      # Mock the on method to simulate event registration and handling
      allow(ws_instance).to receive(:on) do |event, &block|
        case event
        when :message
          # Simulate receiving a message event with response data
          block.call(double('Message', data: response))
        when :open, :close, :error
          # Simulate other events without further action
          block.call(nil)
        end
      end
    end

    it 'stores the subscription callback in @subscriptions' do
      # Set up a callback to capture the result
      callback = double('Callback')
      expect(callback).to receive(:call).with('value' => 'account-data')

      # Subscribe to the account and check @subscriptions
      expect(client.subscriptions).to be_empty # Should be empty before subscribing

      subscription_id = client.subscribe('accountSubscribe', params) do |result|
        callback.call(result)
      end

      # Check that @subscriptions contains the generated id and block
      expect(client.subscriptions).to have_key(subscription_id)
      expect(client.subscriptions[subscription_id]).to be_a(Proc)

      # Verify that the send method was called on the WebSocket instance
      expect(ws_instance).to have_received(:send).with(hash_including(
        jsonrpc: '2.0',
        method: 'accountSubscribe',
        params: params
      ).to_json)

      # Simulate the WebSocket response, triggering the callback
      client.send(:handle_message, JSON.parse(response))
    end
  end
end
