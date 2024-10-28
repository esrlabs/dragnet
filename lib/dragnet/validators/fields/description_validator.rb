# frozen_string_literal: true

require_relative 'field_validator'

module Dragnet
  module Validators
    module Fields
      # Validates the +description+ field for a MTR.
      class DescriptionValidator < Dragnet::Validators::Fields::FieldValidator
        # Validates a MTR's description
        # @param [String] key The name of the key
        # @param [Object] value The value of the key
        # @raise [Dragnet::Errors::ValidationError] If the description contains
        #   anything but a +String+ or +nil+.
        # :reek:NilCheck (Only +nil+ is allowed, +false+ should be considered invalid).
        def validate(key, value)
          return if value.nil?

          validate_type(key, value, String)
        end
      end
    end
  end
end
