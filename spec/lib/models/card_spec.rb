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
      expect(schema.dig :key_properties).to eq %i[cardNumber]
      expect(schema.dig :stream).to eq 'cards'
      expect(schema.dig :type).to eq :SCHEMA

      types = ::TapClutch::Schema::Types

      expect(schema[:schema][:properties]).to eq(
        cardNumber: types.string(:not_null),
        cardSetId: types.string,
        balances: types.array
      )
    end
  end
end
