# frozen_string_literal: true

require './lib/runner.rb'
require 'tempfile'

RSpec.describe TapClutch::Runner do
  let(:argv) { ['-c', config_filename,  '-s', state_filename, '--verbose'] }
  let(:config_filename) { 'config.json' }
  let(:state_filename) { 'state.json' }
  let(:stream) { StringIO.new }
  let(:config) { nil }
  let(:state) { nil }

  let(:runner) do
    TapClutch::Runner.new argv, stream: stream, config: config, state: state
  end

  describe '#initialize' do
    it 'initializes a TapClutch::Runner with the given argv' do
      expect(runner.config_filename).to eq config_filename
      expect(runner.state_filename).to eq state_filename
      expect(runner.verbose).to be true
    end
  end

  %i[config state].each do |attribute|
    describe "##{attribute}" do
      context "with no #{attribute} file" do
        let(:argv) { [] }
        it 'returns an empty hash' do
          expect(runner.send(attribute)).to eq({})
        end
      end

      context "with a #{attribute} file" do
        let(:hash) { { 'foo' => 1 } }

        let("#{attribute}_filename") { file.path }
        let(:file) do
          Tempfile.new("#{attribute}.json").tap do |file|
            file << JSON.generate(hash)
            file.close
          end
        end

        it "assigns the config file JSON contents to `#{attribute}`" do
          expect(runner.send(attribute)).to eq hash
        end
      end
    end
  end

  describe '#perform' do
    context 'with no config' do
      let(:argv) { [] }
      it 'prints usage info' do
        runner.perform
        expect(stream.string).to include('Usage:')
      end
    end

    context 'with config and state' do
      let(:config) do
        {
          'api_key' => 'key',
          'api_secret' => 'secret',
          'api_base' => 'https://api-test.profitpointinc.com:9002/merchant/',
          'brand' => 'brand',
          'location' => 'location',
          'terminal' => 'terminal',
          'username' => 'username',
          'password' => 'password'
        }
      end

      let(:start_date) { '2018-01-15' }
      let(:state) { { 'start_date' => start_date } }
      let(:mock_client) do
        instance_double TapClutch::Client, output: nil, process: nil
      end

      before do
        allow(TapClutch::Client).to receive(:new).and_return mock_client
        runner.perform
      end

      it 'builds a client' do
        expect(TapClutch::Client).to have_received(:new).once.with(
          api_key: 'key',
          api_secret: 'secret',
          api_base: 'https://api-test.profitpointinc.com:9002/merchant/',
          brand: 'brand',
          location: 'location',
          terminal: 'terminal',
          username: 'username',
          password: 'password',
          verbose: true,
          state: { 'start_date' => start_date },
          stream: stream
        )
      end

      it 'outputs a schema for Card records' do
        expect(mock_client).to have_received(:output)
          .with(TapClutch::Models::Card.schema).once
      end

      it 'outputs a schema for Transaction records' do
        expect(mock_client).to have_received(:output)
          .with(TapClutch::Models::Transaction.schema).once
      end

      it 'process records with the start date' do
        expect(mock_client).to have_received(:process).with(start_date).once
      end
    end
  end
end
