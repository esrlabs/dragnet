# frozen_string_literal: true

require_relative '../errors/yaml_format_error'

module Dragnet
  module Validators
    # Base class for all validators.
    class Validator
      private

      # Raises a +Dragnet::Errors::YAMLFormatError+ with the given message.
      # @param [String] message The message for the exception.
      # @raise [Dragnet::Errors::YAMLFormatError] Is always raised with the
      #   given message.
      def yaml_format_error(message)
        raise Dragnet::Errors::YAMLFormatError, message
      end
    end
  end
end
