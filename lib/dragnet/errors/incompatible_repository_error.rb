# frozen_string_literal: true

module Dragnet
  module Errors
    # An error to be raised when an attempt is made to perform an action on a
    # multi-repo set-up which can only be performed on a single-repo set-up.
    # For example, trying to perform a +diff+ operation on the multi-repo root.
    class IncompatibleRepositoryError < Dragnet::Errors::Error; end
  end
end
