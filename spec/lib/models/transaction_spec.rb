# frozen_string_literal: true

require './lib/models/transaction'

RSpec.describe TapClutch::Models::Transaction do
  it { is_expected.to be_a TapClutch::Models::Base }

  describe '#stream' do
    subject(:stream) { described_class.stream }
    it { is_expected.to eq 'transactions' }
  end

  describe '.schema' do
    subject(:schema) { described_class.schema }
    it { is_expected.to be_a Hash }

    it 'returns the correct model schema for a session' do
      expect(schema.dig :key_properties).to eq %i[transactionId]
      expect(schema.dig :stream).to eq 'transactions'
      expect(schema.dig :type).to eq :SCHEMA

      types = ::TapClutch::Schema::Types

      expect(schema[:schema][:properties]).to eq(
        balanceUpdates: types.array,
        callType: types.string,
        cardNumber: types.string(:not_null),
        isLegacy: types.boolean,
        location: types.string,
        requestRef: types.string,
        transactionId: types.string(:not_null),
        transactionTime: types.string
      )
    end
  end

  describe '#transform' do
    subject(:transaction) do
      described_class.new 'transactionTime' => 1_516_120_276_000
    end

    it 'converts transactionTime to a datetime from integer' do
      expect(transaction.transform['transactionTime'])
        .to eq 'Tue, 16 Jan 2018 11:31:16 EST -05:00'
    end
  end
end
