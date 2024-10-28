# frozen_string_literal: true

require_relative 'field_validator'
require_relative '../../errors/validation_error'

module Dragnet
  module Validators
    module Fields
      # Base class to validate the fields that are part of the meta-data group.
      # This means: Either +String+ +Array<String>+ or +nil+ as value.
      class MetaDataFieldValidator < Dragnet::Validators::Fields::FieldValidator
        # Validates the specified attribute as a meta-data field.
        # @param [String] key The name of the key
        # @param [Object] value The value of the key
        # @raise [Dragnet::Errors::ValidationError] If the attribute fails the
        #   validation.
        # @return [nil] If +value+ is +nil+ or an empty array.
        # @return [Array<String>] If +value+ is a +String+ or an +Arry<String>+
        def validate(key, value)
          return unless value

          validate_type(key, value, String, Array)

          if value.is_a?(Array)
            return if value.empty?

            validate_array_types(key, value, String)
            value
          else
            [value]
          end
        end
      end
    end
  end
end
