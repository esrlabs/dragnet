# frozen_string_literal: true

require_relative '../verification_result'
require_relative 'mixins/git_error_handling'
require_relative 'repository_verifier'

module Dragnet
  module Verifiers
    # Checks for changes in the repository since the creation of the MTR Record
    class ChangesVerifier < Dragnet::Verifiers::RepositoryVerifier
      include ::Dragnet::Verifiers::Mixins::GitErrorHandling

      attr_reader :test_records

      # @param [Dragnet::TestRecord] test_record The +TestRecord+ object to
      #   verify.
      # @param [Dragnet::Repository] repository A +Dragnet::Repository+ object
      #   linked to the repository where the verification should be executed.
      # @param [Array<Hash>] test_records The hash of all the test records. This
      #   is used to determine if the changes in the repository are only in the
      #   Test Record Files, in which case the Test Records will still be
      #   considered valid.
      def initialize(test_record:, repository:, test_records:)
        super(test_record: test_record, repository: repository)
        @test_records = test_records
      end

      # Runs the verification process. Checks the changes on the repository
      # between the Commit with the SHA1 registered in the MTR and the current
      # HEAD.
      # @return [Dragnet::VerificationResult, nil] A +VerificationResult+ with
      #   the details of the changes found in the repository or +nil+ if no
      #   changes were found.
      def verify
        diff = repository.diff(sha1, 'HEAD')
        return unless diff.size.positive?

        find_changes(diff)
      rescue Git::FailedError => e
        result_from_git_error(e)
      end

      private

      # Scans the given diff for changes. If changes are detected then a
      # +:result+ key will be added to the +test_record+. Changes to the MTR
      # files themselves are ignored.
      # @return [Dragnet::VerificationResult, nil] A +VerificationResult+ with
      #   the details of the changes found in the repository, or +nil+ if no
      #   changes were found.
      def find_changes(diff)
        diff.stats[:files].each_key do |file|
          next if mtr_files.include?(file) # Changes to MTR files are ignored.

          return Dragnet::VerificationResult.new(
            status: :skipped,
            reason: "Changes detected in the repository: #{shorten_sha1(sha1)}..#{shorten_sha1(repository.head.sha)}"\
                    " # -- #{file}"
          )
        end

        nil
      end

      # @return [Array<Strings>] An array of strings with the paths to all the
      #   known MTR files. These will be excluded when checking from changes in
      #   the repository.
      def mtr_files
        @mtr_files ||= test_records.map do |test_record|
          test_record.source_file.relative_path_from(path).to_s
        end
      end
    end
  end
end
