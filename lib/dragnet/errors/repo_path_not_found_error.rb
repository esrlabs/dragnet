# frozen_string_literal: true

require_relative 'error'

module Dragnet
  module Errors
    # An error to raise when the +path+ given for a +repos+ entry cannot be found.
    class RepoPathNotFoundError < Dragnet::Errors::Error; end
  end
end
