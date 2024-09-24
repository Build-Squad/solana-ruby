require 'spec_helper'

RSpec.describe SolanaRuby::WebSocketMethods::LogMethods do
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

  describe '#on_logs' do
    let(:params) { ['all'] }
    let(:response) do
      {
        jsonrpc: '2.0',
        id: generated_id,
        result: 'log data'
      }.to_json
    end

    it 'sends a subscription request with correct parameters' do
      client.on_logs(params)

      expected_message = {
        jsonrpc: '2.0',
        id: generated_id,
        method: 'logsSubscribe',
        params: params
      }.to_json

      expect(ws_instance).to have_received(:send).with(expected_message)
    end

    it 'handles received messages and triggers callback' do
      callback = double('Callback')
      expect(callback).to receive(:call).with('log data')

      client.on_logs(params) do |result|
        callback.call(result)
      end

      # Simulate WebSocket message event
      @message_callback.call(double('Message', data: response))
    end
  end

  describe '#on_logs_for_account' do
    let(:public_key) { '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g' }
    let(:params) { [{ mentions: [public_key] }] }
    let(:response) do
      {
        jsonrpc: '2.0',
        id: generated_id,
        result: 'log data for account'
      }.to_json
    end

    it 'sends a subscription request for logs related to the account' do
      client.on_logs_for_account(public_key)

      expected_message = {
        jsonrpc: '2.0',
        id: generated_id,
        method: 'logsSubscribe',
        params: params
      }.to_json

      expect(ws_instance).to have_received(:send).with(expected_message)
    end

    it 'handles received messages and triggers callback for the account' do
      callback = double('Callback')
      expect(callback).to receive(:call).with('log data for account')

      client.on_logs_for_account(public_key) do |result|
        callback.call(result)
      end

      # Simulate WebSocket message event
      @message_callback.call(double('Message', data: response))
    end
  end

  describe '#on_logs_for_program' do
    let(:program_id) { 'ExampleProgramId' }
    let(:params) { [{ mentions: [program_id] }] }
    let(:response) do
      {
        jsonrpc: '2.0',
        id: generated_id,
        result: 'log data for program'
      }.to_json
    end

    it 'sends a subscription request for logs related to the program' do
      client.on_logs_for_program(program_id)

      expected_message = {
        jsonrpc: '2.0',
        id: generated_id,
        method: 'logsSubscribe',
        params: params
      }.to_json

      expect(ws_instance).to have_received(:send).with(expected_message)
    end

    it 'handles received messages and triggers callback for the program' do
      callback = double('Callback')
      expect(callback).to receive(:call).with('log data for program')

      client.on_logs_for_program(program_id) do |result|
        callback.call(result)
      end

      # Simulate WebSocket message event
      @message_callback.call(double('Message', data: response))
    end
  end

  describe '#remove_logs_listener' do
    it 'unsubscribes from logs updates' do
      subscription_id = generated_id
      expected_message = {
        jsonrpc: '2.0',
        id: SecureRandom.uuid,
        method: 'logsUnsubscribe',
        params: [subscription_id]
      }.to_json

      client.remove_logs_listener(subscription_id)

      expect(ws_instance).to have_received(:send).with(expected_message)
    end
  end
end
