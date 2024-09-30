require 'spec_helper'

RSpec.describe SolanaRuby::WebSocketMethods::SlotMethods do
  let(:url) { 'wss://api.devnet.solana.com' }
  let(:ws_instance) { double('WebSocket::Client::Simple') }
  let(:client) { SolanaRuby::WebSocketClient.new(url) }
  let(:generated_id) { 'some-unique-id' }

  before do
    allow(WebSocket::Client::Simple).to receive(:connect).and_return(ws_instance)
    allow(ws_instance).to receive(:send)
    
    # Mock WebSocket event handling
    allow(ws_instance).to receive(:on) do |event, &block|
      case event
      when :message
        @message_callback = block
      end
    end

    # Stub SecureRandom to generate predictable IDs
    allow(SecureRandom).to receive(:uuid).and_return(generated_id)
  end

  describe '#on_slot_change' do
    let(:response) do
      {
        jsonrpc: '2.0',
        id: generated_id,
        result: 'slot change data'
      }.to_json
    end

    it 'sends a subscription request for slot change notifications' do
      client.on_slot_change {}

      expected_message = {
        jsonrpc: '2.0',
        id: generated_id,
        method: 'slotSubscribe',
        params: []
      }.to_json

      expect(ws_instance).to have_received(:send).with(expected_message)
    end

    it 'handles received messages and triggers the callback for slot changes' do
      callback = double('Callback')
      expect(callback).to receive(:call).with('slot change data')

      client.on_slot_change do |result|
        callback.call(result)
      end

      # Simulate WebSocket message event
      @message_callback.call(double('Message', data: response))
    end
  end

  describe '#remove_slot_change_listener' do
    let(:subscription_id) { 'some-subscription-id' }

    it 'sends an unsubscribe request for slot change notifications' do
      client.remove_slot_change_listener(subscription_id)

      expected_message = {
        jsonrpc: '2.0',
        id: generated_id,
        method: 'slotUnsubscribe',
        params: [subscription_id]
      }.to_json

      expect(ws_instance).to have_received(:send).with(expected_message)
    end
  end
end
