# frozen_string_literal: true

module Dragnet
  module Errors
    # An error to be raised when there is a formatting problem with a YAML file.
    # For example a missing key. (This error doesn't cover Syntax Errors)
    class YAMLFormatError < Dragnet::Errors::Error; end
  end
end
