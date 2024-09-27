require 'spec_helper'

RSpec.describe SolanaRuby::WebSocketMethods::RootMethods do
  let(:url) { 'wss://api.devnet.solana.com' }
  let(:ws_instance) { double('WebSocket::Client::Simple') }
  let(:client) { SolanaRuby::WebSocketClient.new(url) }
  let(:generated_id) { '58984940-3093-44a1-a0fd-13abaddf57c7' }

  before do
    allow(WebSocket::Client::Simple).to receive(:connect).and_return(ws_instance)
    allow(ws_instance).to receive(:send)
    
    allow(ws_instance).to receive(:on) do |event, &block|
      case event
      when :message
        @message_callback = block
      end
    end

    allow(SecureRandom).to receive(:uuid).and_return(generated_id)
  end

  describe '#on_root_change' do
    let(:response) do
      {
        jsonrpc: '2.0',
        id: generated_id,
        result: 'root data'
      }.to_json
    end
    
    it 'sends a root subscription request' do
      client.on_root_change

      expected_message = {
        jsonrpc: '2.0',
        id: generated_id,
        method: 'rootSubscribe',
        params: []
      }.to_json

      expect(ws_instance).to have_received(:send).with(expected_message)
    end

    it 'handles received root messages and triggers callback' do
      callback = double('Callback')
      expect(callback).to receive(:call).with('root data')

      client.on_root_change do |result|
        callback.call(result)
      end

      # Simulate WebSocket message event
      @message_callback.call(double('Message', data: response))
    end
  end

  describe '#remove_root_listener' do
    it 'unsubscribes from root updates' do
      subscription_id = generated_id
      expected_message = {
        jsonrpc: '2.0',
        id: SecureRandom.uuid,
        method: 'rootUnsubscribe',
        params: [subscription_id]
      }.to_json

      client.remove_root_listener(subscription_id)

      expect(ws_instance).to have_received(:send).with(expected_message)
    end
  end
end
