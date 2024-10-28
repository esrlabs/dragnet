# frozen_string_literal: true

module Dragnet
  module Helpers
    # Some helper methods to use when working with repositories.
    module RepositoryHelper
      # @return [String] The first 10 characters of the given string (normally
      #   used to shorten SHA1s when building messages).
      def shorten_sha1(sha1)
        sha1[0...10]
      end

      # @return [Pathname] The base path of the repository where the MTR and the
      #   source files are located. Used to present relative paths.
      def repo_base
        @repo_base ||= repository.path
      end

      # Transforms the given path into a path relative to the repository's root
      # @param [Pathname] path The absolute path.
      # @return [Pathname] A path relative to the repository's root.
      def relative_to_repo(path)
        path.relative_path_from(repo_base)
      end
    end
  end
end
