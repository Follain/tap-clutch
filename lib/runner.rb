# frozen_string_literal: true

require 'concurrent'
require 'optparse'

require_relative 'client'
require_relative 'schema'
require_relative 'models/base'
require_relative 'models/transaction'

module TapClutch
  # Kicks off tap-clutch process
  class Runner
    attr_reader :config_filename
    attr_reader :state_filename
    attr_reader :stream
    attr_reader :verbose

    def initialize(argv, stream: $stderr, config: nil, state: nil)
      @stream = stream
      @config = config
      @state = state
      parser.parse! argv
    end

    def perform
      return stream.puts(parser) if config.keys.empty?
      output_schemata
      client.process state['start_date']
    end

    def config
      @config ||= read_json(config_filename)
    end

    def state
      @state ||= read_json(state_filename)
    end

    private

    def output_schemata
      TapClutch::Models::Base.subclasses.each do |model|
        client.output model.schema
      end
    end

    # rubocop: disable Metrics/AbcSize
    def client
      @client ||= TapClutch::Client.new(
        api_key: config['api_key'],
        api_secret: config['api_secret'],
        api_base: config['api_base'],
        brand: config['brand'],
        location: config['location'],
        terminal: config['terminal'],
        username: config['username'],
        password: config['password'],
        verbose: verbose,
        state: Concurrent::Hash.new.merge!(state),
        stream: stream
      )
    end
    # rubocop: enable Metrics/AbcSize

    def read_json(filename)
      return JSON.parse(File.read(filename)) if filename
      {}
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
        opts.on('-c', '--config filename', 'Set config file (json)') do |config|
          @config_filename = config
        end

        opts.on('-s', '--state filename', 'Set state file (json)') do |state|
          @state_filename = state
        end

        opts.on('-v', '--verbose', 'Enables verbose logging to STDERR') do
          @verbose = true
        end
      end
    end
  end
end
