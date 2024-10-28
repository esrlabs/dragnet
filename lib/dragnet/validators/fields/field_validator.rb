# frozen_string_literal: true

require_relative '../../errors/validation_error'

module Dragnet
  module Validators
    module Fields
      # Base class for all the validators used to validate individual fields
      # inside entities.
      class FieldValidator
        def validate(_key, _value)
          raise NotImplementedError, "#validate method not implemented in #{self.class}"
        end

        private

        # Validates the presence of a value
        # @param [String, Symbol] key The key associated with the value.
        # @param [Object] value The value to validate.
        # @raise [Dragnet::Errors::ValidationError] If the given value is not
        #   present (i.e. is +nil+)
        def validate_presence(key, value)
          validation_error("Missing required key: #{key}") if value.nil?
        end

        # Validates the type of the given value.
        # @param [String, Symbol] key The key associated with the value.
        # @param [Object] value The value to validate.
        # @param [Array<Class>] expected_types The allowed types for the given
        #   value.
        # @raise [Dragnet::Errors::ValidationError] If the given value has a type
        #   which is not in the given array of expected types.
        def validate_type(key, value, *expected_types)
          return if expected_types.include?(value.class)

          validation_error(
            "Incompatible type for key #{key}: "\
            "Expected #{expected_types.join(', ')} got #{value.class} instead"
          )
        end

        # Raises a +Dragnet::Errors::ValidationError+ with the given message.
        # @param [String] message The message for the error.
        # @raise [Dragnet::Errors::ValidationError] Is always raised.
        def validation_error(message)
          raise Dragnet::Errors::ValidationError, message
        end

        # Validates that all elements inside the given array are of the
        # expected type
        # @param [String, Symbol] key The key associated with the array.
        # @param [Array] array The array whose types should be checked.
        # @param [Class] expected_type The type the elements inside the array
        #   should have.
        # @raise [Dragnet::Errors::ValidationError] If any of the elements inside
        #   the given array is of a different type.
        def validate_array_types(key, array, expected_type)
          incompatible_value = array.find { |val| !val.is_a?(expected_type) }
          return unless incompatible_value

          validation_error(
            "Incompatible type for key #{key}: Expected a Array<#{expected_type}>. "\
            "Found a(n) #{incompatible_value.class} inside the array"
          )
        end
      end
    end
  end
end
