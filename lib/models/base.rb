# frozen_string_literal: true

require_relative '../schema'
require_relative '../hash'

module TapClutch
  module Models
    Base = Struct.new(:data, :client) do # rubocop:disable Metrics/BlockLength
      def self.subclasses
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def self.stream
        raise 'Implement #stream in a subclass'
      end

      def self.key_property
        :id
      end

      def self.schema(&block)
        @schema ||= ::TapClutch::Schema.new(stream, key_property)
        @schema.instance_eval(&block) if block_given?
        @schema.to_hash
      end

      def transform
        data.transform_keys(&:underscore)
      end

      def base_record
        {
          type: 'RECORD',
          stream: self.class.stream,
          record: transform
        }
      end

      def extra_records
        []
      end

      def records
        [base_record] + extra_records.compact.flat_map(&:records)
      end
    end
  end
end
