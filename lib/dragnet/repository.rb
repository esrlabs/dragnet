# frozen_string_literal: true

require 'forwardable'

require_relative 'base_repository'

module Dragnet
  # A small wrapper around a Git Repository object. It provides some useful
  # methods needed during the verify process as well as for reporting.
  class Repository < Dragnet::BaseRepository
    extend Forwardable

    attr_reader :git

    def_delegators :@git, :branch, :branches, :diff

    # Creates a new instance of the class. Tries to open the given path as a Git
    # repository.
    # @param [Pathname] path The path where the root of the repository is located.
    # @raise [ArgumentError] If the given path is not a valid git repository.
    def initialize(path:)
      super
      @git = Git.open(path)
    end

    # @return [Git::Object::Commit] The +Commit+ object at the +HEAD+ of the
    #   repository.
    def head
      @head ||= git.object('HEAD')
    end

    # Returns the URI path of the repository (extracted from its first remote
    # [assumed to be the origin]). Example:
    #
    #   ssh://jenkins@gerrit.int.esrlabs.com:29418/tools/dragnet -> /tools/dragnet
    #
    # @return [String] The URI path of the repository
    def remote_uri_path
      URI.parse(git.remotes.first.url).path
    end

    # @return [FalseClass] It always returns false
    def multi?
      false
    end

    # Returns an array of all the branches that include the given commit.
    # @param [String] commit The SHA1 of the commit to look for.
    # @return [Array<Git::Branch>] An array with all the branches that contain
    #   the given commit.
    def branches_with(commit)
      branches.select { |branch| branch.contains?(commit) }
    end

    # Returns an array of all the branches that include the current HEAD.
    # @return [Array<Git::Branch>] An array with all the branches that contain
    #   the current HEAD.
    def branches_with_head
      @branches_with_head ||= branches_with(head.sha)
    end

    private

    # @param [Symbol] method_name The name of the method that was invoked.
    # @raise [Dragnet::Errors::IncompatibleRepositoryError] Is always raised
    #   with a description of the method that was invoked and a possible cause
    #   for the failure.
    def incompatible_repository(method_name)
      super(
        "Failed to perform the action '#{method_name}' on '#{path}'."\
        ' The path was not set-up as a multi-repo path. If you are running'\
        ' without the --multi-repo command line switch make sure that none of'\
        " your MTRs have a 'repos' attribute or run with the --multi-repo switch"
      )
    end
  end
end
