# frozen_string_literal: true

require_relative 'field_validator'

module Dragnet
  module Validators
    module Fields
      # Validates the ID Field for Manual Test Records
      class IDValidator < Dragnet::Validators::Fields::FieldValidator
        # Validates the Requirement ID(s) of the MTR
        # @param [String] key The name of the key
        # @param [Object] value The value of the key
        # @raise [Dragnet::Errors::ValidationError] If the Requirement ID(s) are
        #   missing, they are not a String or an Array of Strings if they contain
        #   a disallowed character or (in the case of an Array) any of its
        #   elements is not a String.
        def validate(key, value)
          validate_presence(key, value)
          validate_type(key, value, String, Array)

          if value.is_a?(String)
            match = value.match(/,|\s/)
            return unless match

            validation_error(
              "Disallowed character '#{match}' found in the value for key #{key}. "\
              'To use multiple requirement IDs please put them into an array'
            )
          else
            validate_array_types(key, value, String)
          end
        end
      end
    end
  end
end
