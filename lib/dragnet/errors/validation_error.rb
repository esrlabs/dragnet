# frozen_string_literal: true

require_relative 'error'

module Dragnet
  module Errors
    # An error to be raised when an attempt is made to create an entity with
    # invalid data.
    class ValidationError < Dragnet::Errors::Error; end
  end
end
