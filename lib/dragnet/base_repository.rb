# frozen_string_literal: true

require_relative 'errors/incompatible_repository_error'

module Dragnet
  # Base class for Dragnet's repository classes.
  class BaseRepository
    attr_reader :path

    # @param [Pathname] path The path were the repository is located.
    def initialize(path:)
      @path = path
    end

    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    def git
      incompatible_repository(__method__)
    end

    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    def branch
      incompatible_repository(__method__)
    end

    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    def branches
      incompatible_repository(__method__)
    end

    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    def diff
      incompatible_repository(__method__)
    end

    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    def head
      incompatible_repository(__method__)
    end

    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    def remote_uri_path
      incompatible_repository(__method__)
    end

    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    def repositories
      incompatible_repository(__method__)
    end

    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    def branches_with(_commit)
      incompatible_repository(__method__)
    end

    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    def branches_with_head
      incompatible_repository(__method__)
    end

    private

    # @param [String] message The message for the raised error.
    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    #   with the given message.
    def incompatible_repository(message)
      raise Dragnet::Errors::IncompatibleRepositoryError, message
    end
  end
end
