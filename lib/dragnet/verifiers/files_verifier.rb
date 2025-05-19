# frozen_string_literal: true

require_relative '../verification_result'
require_relative 'mixins/git_error_handling'
require_relative 'repository_verifier'

module Dragnet
  module Verifiers
    # Checks if any of the files listed in the MTR have changed since the MTR
    # was created.
    class FilesVerifier < Dragnet::Verifiers::RepositoryVerifier
      include ::Dragnet::Verifiers::Mixins::GitErrorHandling

      # Executes the verification process.
      # Checks the changes in the repository. If a change in one of the files
      # is detected a +:result+ key is added to the MTR, including the detected
      # change.
      # @return [Dragnet::VerificationResult, nil] A +VerificationResult+ object
      #   with the detected changes to the listed files or +nil+ if no changes
      #   are found.
      def verify
        changes = []

        files.each do |file|
          diff = repository.diff(sha1, 'HEAD').path(file.to_s)
          next unless diff.size.positive?

          changes << file
        end

        result_from(changes) if changes.any?
      rescue Git::FailedError => e
        result_from_git_error(e)
      end

      private

      # @return [Array<String>] The paths to the files listed in the MTR file.
      def files
        @files ||= test_record.files.map do |file|
          file.relative_path_from(path)
        end
      end

      # Stores the detected changes on the Test Record
      # @param [Array<String>] changes The array of changed files.
      def result_from(changes)
        Dragnet::VerificationResult.new(
          status: :skipped,
          reason: "Changes detected in listed file(s): #{shorten_sha1(sha1)}..#{shorten_sha1(repository.head.sha)}"\
                  " -- #{changes.join(' ')}"
        )
      end
    end
  end
end
