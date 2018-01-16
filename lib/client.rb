# frozen_string_literal: true

require 'clutch'
require 'faraday-cookie_jar'
require 'faraday_middleware'
require 'active_support/time'

require_relative 'models/card'

module TapClutch
  LIMIT = 25
  KEYS = %i[
    api_key
    api_secret
    api_base
    brand
    location
    terminal
    verbose
    state
    stream
    username
    password
  ].freeze

  # rubocop:disable Metrics/BlockLength
  Client = Struct.new(*KEYS) do
    def initialize(**kwargs)
      super(*members.map { |k| kwargs[k] })
      Clutch.configure do |c|
        c.clutch_api_key = api_key
        c.clutch_api_secret = api_secret
        c.clutch_api_base = api_base
        c.clutch_brand = brand
        c.clutch_location = location
        c.clutch_terminal = terminal
      end
    end

    def faraday
      @faraday ||= build_faraday.tap do |f|
        f.post '/authenticate/userpass', username: username, password: password
      end
    end

    def build_faraday
      # TODO: Extract clutch portal URL to config.json
      Faraday.new(url: 'https://portal.clutch.com') do |builder|
        builder.use :cookie_jar
        builder.request :url_encoded
        builder.response :json
        builder.adapter Faraday.default_adapter
      end
    end

    def process(start_date = '2018-01-11')
      start_date = Date.parse(start_date) if start_date.is_a? String
      (start_date..Time.current.getlocal.to_date).each do |date|
        process_date date
      end
    end

    def output(hash)
      stream.puts JSON.generate(hash)
    end

    private

    def process_date(date)
      response = search(date)
      card_numbers = response.body['lookerData']['data'].map { |x| x[2] }.uniq
      cards = card_numbers.map { |n| Models::Card.fetch(n) }
      output_records Models::Card, cards
      output_state date
    end

    def search(date)
      faraday.post do |req|
        req.url  '/transactions/search.json'
        req.body = {
          searchType: 'processed',
          brandId: 7532,
          groupId: 7533,
          transactionTypes: '3,5,9',
          currentRange: 'Custom Range',
          timeFrom: '00:00:00 am',
          timeTo: '00:00:00 am',
          dateFrom: date.strftime('%Y-%m-%d'),
          dateTo: (date + 1).strftime('%Y-%m-%d')
        }
      end
    end

    def output_records(_model, records)
      records.compact.each do |record|
        record.records.flatten.each do |model_record|
          output model_record
        end
      end
    end

    def output_state(date)
      output type: :STATE, value: { start_date: date }
    end

    def get(model, offset)
      model.fetch offset
    end
  end
end
