# frozen_string_literal: true

require_relative 'error'

module Dragnet
  module Errors
    # An error to be raised when an export target file is given for which the
    # format is unknown (cannot be deduced from its extension).
    class UnknownExportFormatError < Dragnet::Errors::Error; end
  end
end
