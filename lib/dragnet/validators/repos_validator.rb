# frozen_string_literal: true

require_relative '../errors/repo_path_not_found_error'
require_relative 'files_validator'

module Dragnet
  module Validators
    # Validates the +Repo+ objects attached to the given +TestRecord+
    class ReposValidator < Dragnet::Validators::Validator
      attr_reader :test_record, :repos, :path

      # @param [Dragnet::TestRecord] test_record The Test Record to validate.
      # @param [Pathname] path The path where the repositories are supposed to
      #   be located.
      def initialize(test_record, path)
        @test_record = test_record
        @path = path
        @repos = test_record.repos
      end

      # Validates the +Repo+ objects inside the given +TestCase+
      def validate
        return unless repos

        validate_paths
      end

      private

      # Validates the +paths+ of the +Repo+ objects (makes sure the paths
      # exist). Knowing that these paths exist, the +files+ attribute of the
      # +Repo+ object can be validated as well.
      # @raise [Dragnet::Errors::RepoPathNotFoundError] If one or more of the
      #   paths cannot be found.
      # @raise [Dragnet::Errors::FileNotFoundError] If any of the files listed
      #   in the +files+ attribute do not exist inside the given +path+.
      def validate_paths
        repos.each do |repo|
          repo_path = repo.path = repo.path.gsub('\\', '/')
          repo_path = Pathname.new(repo_path)

          complete_path = repo_path.absolute? ? repo_path : path / repo_path

          if complete_path.exist?
            validate_files(repo, complete_path)
            next
          end

          repo_path_not_found(repo_path)
        end
      end

      # Validates the existence of the files listed in the +files+ attributes
      # inside the +Repo+ object inside the +Repo+'s +path+.
      # @param [Dragnet::Repo] repo The +Repo+ whose files should be validated.
      # @param [Pathname] complete_path The path to the repository.
      def validate_files(repo, complete_path)
        return unless repo.files

        Dragnet::Validators::FilesValidator.new(repo, complete_path).validate
      end

      # Raises a Dragnet::Errors::RepoPathNotFoundError with the appropriate
      # message (which depends on whether the path is absolute or relative).
      # @param [Pathname] repo_path The path that couldn't be found.
      # @raise [Dragnet::Errors::RepoPathNotFoundError] is always raised.
      def repo_path_not_found(repo_path)
        message = "Cannot find the repository path #{repo_path}"
        message += " inside #{path}" if repo_path.relative?
        raise Dragnet::Errors::RepoPathNotFoundError, message
      end
    end
  end
end
