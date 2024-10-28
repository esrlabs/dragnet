# frozen_string_literal: true

require_relative 'field_validator'

module Dragnet
  module Validators
    module Fields
      # Validates the SHA1 field of a Manual Test Record
      class SHA1Validator < Dragnet::Validators::Fields::FieldValidator
        SHA1_MIN_LENGTH = 7
        SHA1_MAX_LENGTH = 40
        SHA1_REGEX = /\A[0-9a-f]+\Z/.freeze

        # Validates the SHA1 of the MTR
        # @param [String] key The name of the key
        # @param [Object] value The value of the key
        # @raise [Dragnet::Errors::ValidationError] If the SHA1 is missing, is not
        #   and string, is too short or too long or is not a valid hexadecimal
        #   string.
        def validate(key, value)
          validate_presence(key, value)
          validate_type(key, value, String)

          length = value.length
          unless length >= SHA1_MIN_LENGTH && length <= SHA1_MAX_LENGTH
            validation_error(
              "Invalid value for key #{key}: '#{value}'. Expected a string between "\
              "#{SHA1_MIN_LENGTH} and #{SHA1_MAX_LENGTH} characters"
            )
          end

          return if value.match(SHA1_REGEX)

          validation_error(
            "Invalid value for key #{key}: '#{value}'. "\
            "Doesn't seem to be a valid hexadecimal string"
          )
        end
      end
    end
  end
end
