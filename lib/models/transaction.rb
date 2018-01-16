# frozen_string_literal: true

require_relative 'base'
require 'byebug'
require 'active_support/time'

module TapClutch
  module Models
    # Models a Clutch Transaction
    class Transaction < Base
      def self.key_property
        :transactionId
      end

      def self.stream
        'transactions'
      end

      def self.history(card_number)
        response = Clutch.client.post(
          '/cardHistory',
          limit: 100,
          offset: 0,
          cardNumber: card_number,
          restrictTransactionTypes: %w[ALLOCATE UPDATE_BALANCE]
        )

        response.transactions.map do |transaction|
          new(transaction.merge(cardNumber: card_number))
        end
      end

      schema do
        string :transactionId, :not_null
        string :cardNumber, :not_null
        string :requestRef
        string :callType
        boolean :isLegacy
        string :location
        string :transactionTime
        array :balanceUpdates
      end

      def transform
        Time.zone = Time.now.zone

        super.tap do |data|
          data.merge! 'transactionTime' =>
            Time.zone.at(data['transactionTime'] / 1000)
        end
      end
    end
  end
end
