# frozen_string_literal: true

require_relative 'error'

module Dragnet
  module Errors
    # An error to be raised when Dragnet cannot write to one of the given export
    # files.
    class UnableToWriteReportError < Dragnet::Errors::Error; end
  end
end
