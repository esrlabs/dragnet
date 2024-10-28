# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/hash/keys'

require_relative '../test_record'
require_relative 'validator'

module Dragnet
  module Validators
    # Validates the data (key-value pairs) inside an MTR file. Verifies the
    # structure, the required keys and their types.
    class DataValidator < Dragnet::Validators::Validator
      attr_reader :data, :source_file

      # Creates a new instance of the class
      # @param [Hash] data The data inside the YAML (after parsing)
      # @param [Pathname] source_file The path to the file from which the MTR
      #   data was loaded.
      def initialize(data, source_file)
        @data = data
        @source_file = source_file
      end

      # Validates the given data
      # @return [Dragnet::TestRecord] A +TestRecord+ object created
      #   from the given data (if the data was valid).
      # @raise [Dragnet::Errors::YAMLFormatError] If the data is invalid. The
      #   raised exceptions contains a message specifying why the data is
      #   invalid.
      def validate
        yaml_format_error("Incompatible data structure. Expecting a Hash, got a #{data.class}") unless data.is_a?(Hash)
        data.deep_symbolize_keys!

        # A call to chomp for strings is needed because the following YAML
        # syntax:
        #
        # findings: >
        #      no findings
        #
        # causes the string values to end with a newline ("\n"):
        data.transform_values! { |value| value.is_a?(String) ? value.chomp : value }
        test_record = create_mtr(data)
        validate_mtr(test_record)
      end

      private

      # @param [Hash] data A hash with the data for the +TestRecord+
      # @see Dragnet::TestRecord#initialize
      def create_mtr(data)
        Dragnet::TestRecord.new(data).tap do |test_record|
          test_record.source_file = source_file
        end
      end

      # Creates a +Dragnet::TestRecord+ with the given data and runs its
      # validation. If the validation is successful the +TestRecord+
      # object is returned, if the validation fails an error is raised.
      # @param [Dragnet::TestRecord] test_record The +TestRecord+ object to
      #   validate.
      # @return [Dragnet::TestRecord] The given +TestRecord+ object if the
      #   validation passed.
      # @raise [Dragnet::Errors::YAMLFormatError] If the data is invalid. The
      #   raised exceptions contains a message specifying why the data is
      #   invalid.
      def validate_mtr(test_record)
        test_record.validate
        test_record
      rescue Dragnet::Errors::ValidationError => e
        yaml_format_error(e.message)
      end
    end
  end
end
