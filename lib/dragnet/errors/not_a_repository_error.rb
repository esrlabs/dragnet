# frozen_string_literal: true

require_relative 'error'

module Dragnet
  module Errors
    # An error to be raised when the path of a repository entry in a MTR with
    # multiple repositories doesn't point to an actual git repository.
    class NotARepositoryError < Dragnet::Errors::Error; end
  end
end
