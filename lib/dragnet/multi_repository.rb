# frozen_string_literal: true

require_relative 'base_repository'

module Dragnet
  # This is a dummy class that acts as a placeholder when Dragnet is executed
  # on a multi-repo set-up. Since there is no Git repository in the directory
  # where git-repo runs git commands cannot be executed there only in the inner
  # repositories.
  #
  # This class's job is to raise a particular error when a git operation is
  # attempted directly on this directory so that Dragnet can recognize the cause
  # of the error and display it correctly.
  #
  # It also acts as a collection of repositories. It stores a collection of
  # +Dragnet::Repository+ objects, which point to the actual repositories (this
  # is just so that the same repository isn't initialized multiple times).
  class MultiRepository < Dragnet::BaseRepository
    attr_reader :repositories

    # @param [Pathname] path Path to the directory where the inner repositories
    #   reside.
    def initialize(path:)
      super
      @repositories = {}
    end

    # @return [TrueClass] It always returns true
    def multi?
      true
    end

    private

    # @param [Symbol] method_name The name of the method that was invoked.
    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    #   with a description of the method that was invoked and a possible cause
    #   for the failure.
    def incompatible_repository(method_name)
      super(
        "Failed to perform the action '#{method_name}' on '#{path}'."\
        " There isn't a git repository there. If you are running with the"\
        ' --multi-repo command line switch make sure that all of your MTRs'\
        " contain a valid 'repos' attribute."
      )
    end
  end
end
