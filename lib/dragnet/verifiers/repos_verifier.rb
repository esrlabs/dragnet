# frozen_string_literal: true

require_relative '../errors/not_a_repository_error'
require_relative '../test_record'
require_relative 'changes_verifier'
require_relative 'files_verifier'
require_relative 'verifier'

module Dragnet
  module Verifiers
    # Verifies the +Repo+ objects attached to a +TestRecord+
    class ReposVerifier < Dragnet::Verifiers::Verifier
      attr_reader :multi_repository

      # @param [Dragnet::TestRecord] test_record The +TestRecord+ object to
      #   verify.
      # @param [Dragnet::MultiRepository] multi_repository The +MultiRepository+
      #   object that is supposed to contain the actual repositories inside.
      def initialize(test_record:, multi_repository:)
        super(test_record: test_record)
        @multi_repository = multi_repository
      end

      # Carries out the verification of the +Repo+ objects.
      # @return [Dragnet::VerificationResult, nil] A +VerificationResult+ object
      #   when the verification of any of the listed repositories fails and
      #   +nil+ when all of them pass the verification.
      def verify
        return unless test_record.repos&.any?

        test_record.repos.each do |repo|
          repository = fetch_repository(repo.path, multi_repository)
          verification_result = verify_repo(repo, repository)

          return verification_result if verification_result
        end
      rescue Dragnet::Errors::NotARepositoryError => e
        Dragnet::VerificationResult.new(status: :failed, reason: e.message)
      end

      private

      # Verifies the given +Repo+ object using the given +Dragnet::Repository+
      # object and a Proxy TestRecord object.
      # @param [Dragnet::Repo] repo +Repo+ the +Repo+ object to verify.
      # @param [Dragnet::Repository] repository The +Repository+ object that
      #   actually contains the source the +Repo+ object is referring to.
      # @return [Dragnet::VerificationResult, nil] A +VerificationResult+ object
      #   when the verification fails or +nil+ when the verification passes.
      def verify_repo(repo, repository)
        # The Proxy TestRecord object allows the use of the +FilesVerifier+ and
        # the +ChangesVerifier+ since they expect a +TestRecord+ and not a
        # +Repo+ object.
        proxy_test_record = Dragnet::TestRecord.new(files: repo.files, sha1: repo.sha1)

        if repo.files
          Dragnet::Verifiers::FilesVerifier
            .new(test_record: proxy_test_record, repository: repository).verify
        else
          Dragnet::Verifiers::ChangesVerifier
            .new(test_record: proxy_test_record, repository: repository, test_records: []).verify
        end
      end

      # Fetches the +Repository+ object associated with the given path from the
      # given +MultiRepository+ object.
      # @param [Pathname] path The path of the repository.
      # @param [Dragnet::MultiRepository] multi_repository The +MultiRepository+
      #   object that contains the repository to be fetched.
      # @return [Dragnet::Repository] The +Repository+ object associated with
      #   the given path.
      def fetch_repository(path, multi_repository)
        multi_repository.repositories[path] ||= create_repository(multi_repository, path)
      end

      # Creates a new repository with the given path.
      # @param [Dragnet::MultiRepository] multi_repository The +MultiRepository+
      #   object in which the individual repository should be created.
      # @param [Pathname] path The path for the +Repository+ object.
      # @return [Dragnet::Repository] The resulting +Repository+ object.
      # @raise [Dragnet::Errors::NotARepositoryError] If the given path doesn't
      #   lead to a valid git repository or the repository cannot be opened.
      def create_repository(multi_repository, path)
        repository_path = multi_repository.path / path
        Dragnet::Repository.new(path: repository_path)
      rescue ArgumentError
        raise Dragnet::Errors::NotARepositoryError,
              "The path '#{path}' does not contain a valid git repository."
      end
    end
  end
end
