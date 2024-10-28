# frozen_string_literal: true

require_relative 'field_validator'

module Dragnet
  module Validators
    module Fields
      # Validates the result field of an MTR Record
      class ResultValidator < Dragnet::Validators::Fields::FieldValidator
        VALID_RESULTS = %w[passed failed].freeze

        # Validates the MTR's result
        # @param [String] key The name of the key
        # @param [Object] value The value of the key
        # @return [String] The downcase version of the result field.
        # @raise [Dragnet::Errors::ValidationError] If the result is missing, if
        #   it isn't a String or is not one of the allowed values for the field.
        def validate(key, value)
          validate_presence(key, value)
          validate_type(key, value, String)

          value = value.downcase
          return value if VALID_RESULTS.include?(value)

          validation_error(
            "Invalid value for key result: '#{value}'. "\
            "Valid values are #{VALID_RESULTS.join(', ')}"
          )
        end
      end
    end
  end
end
