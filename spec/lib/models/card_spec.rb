# frozen_string_literal: true

require './lib/models/card'

RSpec.describe TapClutch::Models::Card do
  it { is_expected.to be_a TapClutch::Models::Base }

  describe '#stream' do
    subject(:stream) { described_class.stream }
    it { is_expected.to eq 'cards' }
  end

  describe '.schema' do
    subject(:schema) { described_class.schema }
    it { is_expected.to be_a Hash }

    it 'returns the correct model schema for a session' do
      expect(schema.dig :key_properties).to eq %i[card_number]
      expect(schema.dig :stream).to eq 'cards'
      expect(schema.dig :type).to eq :SCHEMA

      types = ::TapClutch::Schema::Types

      expect(schema[:schema][:properties]).to eq(
        card_number: types.string(:not_null),
        card_set_id: types.string,
        activation_date: types.string,
        balances: types.array
      )
    end
  end
end
