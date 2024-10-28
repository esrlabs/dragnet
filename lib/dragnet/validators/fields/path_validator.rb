# frozen_string_literal: true

require_relative 'field_validator'

module Dragnet
  module Validators
    module Fields
      # Validates the +path+ attribute of a +Repo+ object.
      class PathValidator < Dragnet::Validators::Fields::FieldValidator
        # Validates the Path of the repository.
        # @param [String] key The name of the key
        # @param [Object] value The value of the key
        # @raise [Dragnet::Errors::ValidationError] If the path is missing, or
        #   it isn't a String.
        def validate(key, value)
          validate_presence(key, value)
          validate_type(key, value, String)
        end
      end
    end
  end
end
