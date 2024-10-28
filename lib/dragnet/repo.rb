# frozen_string_literal: true

require_relative 'validators/entities/repo_validator'

module Dragnet
  # Represents a repository, (for MTRs which reference multiple repositories in
  # a multi-repo project, often managed with git-repo)
  class Repo
    attr_accessor :path, :sha1, :files

    # @param [Hash] args The data for the Repo
    # @option args [String] :path The path where the repository is stored.
    # @option args [String] :sha1 The SHA1 the repository had when the MTR was
    #   created.
    # @option args [String, Array<String>, nil] :files The file or array of
    #   files covered by the MTR.
    def initialize(args)
      @path = args[:path]
      @sha1 = args[:sha1]
      @files = args[:files]
    end

    # Validates the +Repo+ instance (by checking each of its attributes).
    # @raise [Dragnet::Errors::ValidationError] If any of the attributes of the
    #   +Repo+ object is invalid.
    # @see Dragnet::Validators::Entities::RepoValidator#validate
    def validate
      Dragnet::Validators::Entities::RepoValidator.new(self).validate
    end
  end
end
