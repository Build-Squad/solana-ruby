require 'spec_helper'

RSpec.describe SolanaRuby::WebSocketMethods::SignatureMethods do
  let(:url) { 'wss://api.devnet.solana.com' }
  let(:ws_instance) { double('WebSocket::Client::Simple') }
  let(:client) { SolanaRuby::WebSocketClient.new(url) }
  let(:generated_id) { '58984940-3093-44a1-a0fd-13abaddf57c7' }

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

  describe '#on_signature' do
    let(:signature) { '5Nc57f1tyHFfrtrtw4RQMGWscBz4TQgWRvjMfT1wePqfE1bZmB' }
    let(:options) { { commitment: 'finalized' } }
    let(:params) { [signature, options] }
    let(:response) do
      {
        jsonrpc: '2.0',
        id: generated_id,
        result: 'signature confirmation'
      }.to_json
    end
    
    it 'sends a subscription request for signature updates' do
      client.on_signature(signature, options)

      expected_message = {
        jsonrpc: '2.0',
        id: generated_id,
        method: 'signatureSubscribe',
        params: params
      }.to_json

      expect(ws_instance).to have_received(:send).with(expected_message)
    end

    it 'handles received messages and triggers callback for signature updates' do
      callback = double('Callback')
      expect(callback).to receive(:call).with('signature confirmation')

      client.on_signature(signature, options) do |result|
        callback.call(result)
      end

      # Simulate WebSocket message event
      @message_callback.call(double('Message', data: response))
    end
  end

  describe '#on_signature_with_options' do
    let(:signature) { '5Nc57f1tyHFfrtrtw4RQMGWscBz4TQgWRvjMfT1wePqfE1bZmB' }
    let(:options) { { commitment: 'confirmed', encoding: 'json' } }
    let(:params) { [signature, options] }
    let(:response) do
      {
        jsonrpc: '2.0',
        id: generated_id,
        result: 'signature confirmation'
      }.to_json
    end

    it 'sends a subscription request with the correct parameters and options' do
      client.on_signature_with_options(signature, options)

      expected_message = {
        jsonrpc: '2.0',
        id: generated_id,
        method: 'signatureSubscribe',
        params: params
      }.to_json

      expect(ws_instance).to have_received(:send).with(expected_message)
    end

    it 'handles received messages and triggers callback for the signature' do
      callback = double('Callback')
      expect(callback).to receive(:call).with('signature confirmation')

      client.on_signature_with_options(signature, options) do |result|
        callback.call(result)
      end

      # Simulate WebSocket message event
      @message_callback.call(double('Message', data: response))
    end
  end

  describe '#remove_signature_listener' do
    it 'unsubscribes from signature updates' do
      subscription_id = generated_id
      expected_message = {
        jsonrpc: '2.0',
        id: SecureRandom.uuid,
        method: 'signatureUnsubscribe',
        params: [subscription_id]
      }.to_json

      client.remove_signature_listener(subscription_id)

      expect(ws_instance).to have_received(:send).with(expected_message)
    end
  end
end
