# frozen_string_literal: true

require_relative 'base'
require 'active_support/time'

module TapClutch
  module Models
    # Models a Clutch Transaction
    class Transaction < Base
      def self.key_property
        :transaction_id
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
        string :transaction_id, :not_null
        string :card_number, :not_null
        string :request_ref
        string :call_type
        boolean :is_legacy
        string :location
        string :transaction_time
        array :balance_updates
      end

      def transform
        Time.zone = Time.now.zone

        super.tap do |data|
          data.merge! 'transaction_time' =>
            Time.zone.at(data['transaction_time'] / 1000)
        end
      end
    end
  end
end
