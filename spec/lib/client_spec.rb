
# frozen_string_literal: true

require './lib/client'
require './lib/models/card'
require 'timecop'

RSpec.describe TapClutch::Client do
  let(:verbose) { false }
  let(:state) { {} }
  let(:token) { 'clutch-ai-token' }
  let(:stream) { StringIO.new }
  let(:api_key) { 'api-key' }
  let(:api_secret) { 'api-secret' }
  let(:api_base) { 'https://api-base.example.com' }
  let(:brand) { 'brand' }
  let(:location) { 'location' }
  let(:terminal) { 'terminal' }
  let(:username) { 'username' }
  let(:password) { 'password' }

  let(:client) do
    described_class.new(
      api_base: api_base,
      api_key: api_key,
      api_secret: api_secret,
      brand: brand,
      location: location,
      password: password,
      state: state,
      stream: stream,
      terminal: terminal,
      username: username,
      verbose: verbose
    )
  end

  describe 'initialize' do
    it 'sets token, verbose, state, stream' do
      expect(client.verbose).to eq verbose
      expect(client.state).to eq state
      expect(client.stream).to eq stream
    end
  end

  describe '#output' do
    it 'serializes JSON of the hash to its stream' do
      client.output foo: 1
      client.output bar: 2

      expect(stream.string)
        .to eq "#{JSON.generate(foo: 1)}\n#{JSON.generate(bar: 2)}\n"
    end
  end

  describe '#process', vcr: { cassette_name: :process } do
    around { |example| Timecop.freeze '2018-01-16', &example.method(:run) }

    it 'fetches cards and transactions and outputs to its stream' do
      client.process('2018-01-14')

      lines = stream.string.split("\n")
      outputs = lines.map { |line| JSON.parse(line) }
      expect(outputs.size).to eq 64

      card = outputs.first

      expect(card['type']).to eq 'RECORD'
      expect(card['stream']).to eq 'cards'
      expect(card['record'].keys)
        .to eq %w[cardNumber cardSetId balances activationDate]
      expect(card['record']['cardNumber']).to be_a String
      expect(card['record']['cardSetId']).to be_a String
      expect(card['record']['balances']).to be_an Array
      expect(card['record']['activationDate']).to be_a String

      transaction = outputs[1]
      expect(transaction['type']).to eq 'RECORD'
      expect(transaction['stream']).to eq 'transactions'
      expect(transaction['record'].keys)
        .to eq %w[
          transactionId isLegacy transactionTime
          location callType balanceUpdates requestRef cardNumber
        ]

      expect(transaction['record']['transactionId']).to be_a String
      expect(transaction['record']['isLegacy']).to be_a FalseClass
      expect(transaction['record']['transactionTime'])
        .to eq '2018-01-14 12:28:10 -0500'
      expect(transaction['record']['location']).to be_a String
      expect(transaction['record']['callType']).to be_a String
      expect(transaction['record']['balanceUpdates']).to be_an Array
      expect(transaction['record']['requestRef']).to be_a String
      expect(transaction['record']['cardNumber']).to be_a String

      expect(outputs.last['type']).to eq 'STATE'
      expect(outputs.last['value']).to eq('start_date' => '2018-01-16')
    end
  end
end
