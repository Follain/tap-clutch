# frozen_string_literal: true

require_relative 'base'
require_relative 'transaction'

module TapClutch
  module Models
    # Models a Clutch Card
    class Card < Base
      def self.key_property
        :card_number
      end

      def self.stream
        'cards'
      end

      schema do
        string :card_number, :not_null
        string :card_set_id
        string :activation_date
        array :balances
      end

      def self.fetch(card_number)
        response = Clutch.client.post(
          '/search',
          limit: 1,
          offset: 0,
          filters: {
            cardNumber: card_number
          },
          returnFields: {
            balances: true,
            activationDate: true
          }
        )

        new(response.cards.first) if response.cards.first
      end

      def extra_records
        Transaction.history(data.cardNumber)
      end
    end
  end
end
