require 'spec_helper'

RSpec.describe SolanaRuby::WebSocketMethods::AccountMethods do
  let(:url) { 'wss://api.devnet.solana.com' }
  let(:ws_instance) { double('WebSocket::Client::Simple') }
  let(:new_ws_instance) { double('WebSocket::Client::Simple') }
  let(:client) { SolanaRuby::WebSocketClient.new(url, auto_reconnect: true, reconnect_delay: 1) }
  let(:generated_id) { '58984940-3093-44a1-a0fd-13abaddf57c7' }

  before do
    # Mock WebSocket connection setup
    allow(WebSocket::Client::Simple).to receive(:connect).and_return(ws_instance)

    # Mock the send method
    allow(ws_instance).to receive(:send)

    # Handle WebSocket events with explicit control
    allow(ws_instance).to receive(:on) do |event, &block|
      case event
      when :message
        @message_callback = block
      when :open
        @open_callback = block
      when :close
        @close_callback = block
      when :error
        @error_callback = block
      end
    end

    # Mock SecureRandom to generate predictable IDs
    allow(SecureRandom).to receive(:uuid).and_return(generated_id)

    # Set initial WebSocket instance for client
    client.instance_variable_set(:@ws, ws_instance)
  end

  describe '#on_account_change' do
    let(:account_address) { '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g' }
    let(:params) { [account_address, { "commitment": "finalized" }] }
    let(:response) do
      {
        jsonrpc: '2.0',
        id: generated_id,
        result: 123456789
      }.to_json
    end

    it 'sends a subscription request with correct parameters' do
      client.on_account_change(account_address)

      expected_message = {
        jsonrpc: '2.0',
        id: generated_id,
        method: 'accountSubscribe',
        params: params
      }.to_json

      expect(ws_instance).to have_received(:send).with(expected_message)
    end

    it 'handles received messages and triggers subscription callbacks' do
      callback = double('Callback')
      expect(callback).to receive(:call).with(123456789)

      client.on_account_change(account_address) do |result|
        callback.call(result)
      end

      # Simulate WebSocket message event
      @message_callback.call(double('Message', data: response))
    end

    it 'attempts to reconnect on connection close if auto_reconnect is true' do
      # Stub the initial WebSocket connection
      allow(WebSocket::Client::Simple).to receive(:connect).and_return(ws_instance)

      # Stub the WebSocket's close method to allow it to be called
      allow(ws_instance).to receive(:close)

      # Stub reconnection
      allow(WebSocket::Client::Simple).to receive(:connect).and_return(new_ws_instance)
      allow(new_ws_instance).to receive(:send)
      allow(new_ws_instance).to receive(:on) do |event, &block|
        case event
        when :message
          @message_callback = block
        when :open
          @open_callback = block
        when :close
          @close_callback = block
        when :error
          @error_callback = block
        end
      end

      # Ensure that the WebSocket is initially connected
      client.connect

      # Check that the initial connection is established
      expect(WebSocket::Client::Simple).to have_received(:connect).once

      # Simulate a close event on the WebSocket instance
      @close_callback.call(nil) if @close_callback

      # Allow time for reconnection to be attempted
      sleep(0.1)  # Reduce sleep duration for quicker test runs

      # Ensure that the connect method was called twice (initial + reconnect)
      expect(WebSocket::Client::Simple).to have_received(:connect).twice

      # Optionally, check that the client state reflects a reconnection attempt
      expect(client.instance_variable_get(:@connected)).to be_truthy
    end
  end

  describe '#remove_account_change_listener' do
    let(:account_address) { '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g' }
    let(:subscription_id) { generated_id }

    it 'unsubscribes from account change notifications' do
      client.on_account_change(account_address)

      expected_unsubscribe_message = {
        jsonrpc: '2.0',
        id: SecureRandom.uuid,
        method: 'accountUnsubscribe',
        params: [subscription_id]
      }.to_json

      client.remove_account_change_listener(subscription_id)

      expect(ws_instance).to have_received(:send).with(expected_unsubscribe_message)
    end

    it 'removes the subscription from the subscriptions hash' do
      client.on_account_change(account_address)
      client.remove_account_change_listener(subscription_id)

      expect(client.subscriptions).not_to have_key(subscription_id)
    end
  end

  describe '#on_program_account_change' do
    let(:program_id) { '11111111111111111111111111111111' }
    let(:response) do
      {
        jsonrpc: '2.0',
        id: generated_id,
        result: 'account data'
      }.to_json
    end

    context 'with default parameters' do
      it 'sends a subscription request with default encoding and commitment' do
        client.on_program_account_change(program_id)

        expected_message = {
          jsonrpc: '2.0',
          id: generated_id,
          method: 'programSubscribe',
          params: [program_id, { encoding: 'base64', commitment: 'finalized' }]
        }.to_json

        expect(ws_instance).to have_received(:send).with(expected_message)
      end

      it 'handles received messages and triggers callback for program account changes' do
        callback = double('Callback')
        expect(callback).to receive(:call).with('account data')

        client.on_program_account_change(program_id) do |result|
          callback.call(result)
        end

        # Simulate WebSocket message event
        @message_callback.call(double('Message', data: response))
      end
    end

    context 'with custom encoding' do
      it 'sends a subscription request with jsonParsed encoding' do
        client.on_program_account_change(program_id, { encoding: 'jsonParsed', commitment: 'finalized' })

        expected_message = {
          jsonrpc: '2.0',
          id: generated_id,
          method: 'programSubscribe',
          params: [program_id, { encoding: 'jsonParsed', commitment: 'finalized' }]
        }.to_json

        expect(ws_instance).to have_received(:send).with(expected_message)
      end
    end

    context 'with filters' do
      let(:filters) { [{ dataSize: 80 }] }

      it 'sends a subscription request with filters' do
        client.on_program_account_change(program_id, { encoding: 'base64', commitment: 'finalized' }, filters)

        expected_message = {
          jsonrpc: '2.0',
          id: generated_id,
          method: 'programSubscribe',
          params: [program_id, { encoding: 'base64', commitment: 'finalized', filters: filters }]
        }.to_json

        expect(ws_instance).to have_received(:send).with(expected_message)
      end
    end
  end

  describe '#remove_program_account_listener' do
    it 'unsubscribes from program account change updates' do
      subscription_id = generated_id
      expected_message = {
        jsonrpc: '2.0',
        id: SecureRandom.uuid,
        method: 'programUnsubscribe',
        params: [subscription_id]
      }.to_json

      client.remove_program_account_listener(subscription_id)

      expect(ws_instance).to have_received(:send).with(expected_message)
    end
  end
end
