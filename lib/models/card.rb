# frozen_string_literal: true

require_relative 'base'
require_relative 'transaction'
require_relative '../hash'

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

        return unless response.cards.first
        new(response.cards.first.to_h.transform_keys(&:underscore))
      end

      def extra_records
        Transaction.history(data['card_number'])
      end
    end
  end
end
