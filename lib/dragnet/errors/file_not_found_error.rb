# frozen_string_literal: true

require_relative 'error'

module Dragnet
  module Errors
    # An error to be raised when one of the files referenced by a MTR File
    # doesn't exist in the repository.
    class FileNotFoundError < Dragnet::Errors::Error; end
  end
end
