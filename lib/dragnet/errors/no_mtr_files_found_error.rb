# frozen_string_literal: true

require_relative 'error'

module Dragnet
  module Errors
    # An error to be raised when the +Explorer+ is unable to locate MTR files
    # with the given glob patterns inside the specified path.
    class NoMTRFilesFoundError < Dragnet::Errors::Error; end
  end
end
