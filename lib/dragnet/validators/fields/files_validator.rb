# frozen_string_literal: true

require_relative 'field_validator'

module Dragnet
  module Validators
    module Fields
      # Validates the files field on a Manual Test Record
      class FilesValidator < Dragnet::Validators::Fields::FieldValidator
        # Validates the MTR's +files+ array.
        # @param [String] key The name of the key
        # @param [Object] value The value of the key
        # @return [Array<String>, nil] If +files+ is an Array or a String then
        #   an array is returned, if +files+ is +nil+ then +nil+ is returned.
        # @raise [Dragnet::Errors::ValidationError] If the +files+ key is not a
        #   +String+ or an +Array+ of +String+s.
        def validate(key, value)
          return unless value

          validate_type(key, value, String, Array)
          value = *value
          validate_array_types(key, value, String)

          value
        end
      end
    end
  end
end
