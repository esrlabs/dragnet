# frozen_string_literal: true

require_relative 'error'

module Dragnet
  module Errors
    # An error to be raised when an attempt is made to retrieve the runtime
    # when one or more timestamp attributes are missing.
    class MissingTimestampAttributeError < Dragnet::Errors::Error; end
  end
end
