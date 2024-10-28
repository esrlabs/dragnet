# frozen_string_literal: true

require_relative 'changes_verifier'
require_relative 'files_verifier'
require_relative 'repos_verifier'
require_relative 'result_verifier'
require_relative 'verifier'

module Dragnet
  module Verifiers
    # Performs the verification process over a single TestRecord object.
    class TestRecordVerifier < Dragnet::Verifiers::Verifier
      attr_reader :repository, :test_records

      # @param [Dragnet::TestRecord] test_record The +TestRecord+ object to
      #   verify.
      # @param [Dragnet::BaseRepository] repository An object representing the
      #   repository the test record is referring to.
      # @param [Array<Dragnet::TestRecord>] test_records An array with all the
      #   +TestRecord+ objects found in the +Repository+. These are needed when
      #   changes to the repository are being verified. Changes targeting the
      #   MTRs only are ignored by the verifiers.
      def initialize(test_record:, repository:, test_records:)
        super(test_record: test_record)
        @repository = repository
        @test_records = test_records
      end

      # Performs the verification and attaches the corresponding
      # +VerificationResult+ object to the +TestRecord+ object.
      # @return [Dragnet::VerificationResult] The result of the verification
      #   process executed over the given +test_record+.
      def verify
        verification_result = verify_result

        verification_result ||= if test_record.files
                                  verify_files
                                elsif test_record.repos
                                  verify_repos
                                else
                                  verify_changes
                                end

        verification_result || Dragnet::VerificationResult.new(status: :passed)
      end

      private

      # Verifies the MTR's +result+ attribute.
      # @return [Dragnet::VerificationResult, nil] A +VerificationResult+ object
      #   when the verification fails and +nil+ when the verification passes.
      def verify_result
        Dragnet::Verifiers::ResultVerifier.new(test_record: test_record).verify
      end

      # Verifies the files listed in the MTR, if any.
      # @return [Dragnet::VerificationResult, nil] A +VerificationResult+ object
      #   with the detected changes to the listed files or +nil+ if no changes
      #   are found.
      def verify_files
        Dragnet::Verifiers::FilesVerifier
          .new(test_record: test_record, repository: repository).verify
      end

      # Verifies the repositories listed in the MTR, only applies when working
      #   with a {Dragnet::MultiRepository} repository.
      # @return [Dragnet::VerificationResult, nil] A +VerificationResult+ object
      #   when the verification of any of the listed repositories fails and
      #   +nil+ when all of them pass the verification.
      def verify_repos
        Dragnet::Verifiers::ReposVerifier.new(test_record: test_record, multi_repository: repository).verify
      end

      # Verifies the changes in the repository between the revision referenced
      # in the MTR and the tip of the current branch.
      # @return [Dragnet::VerificationResult, nil] A +VerificationResult+ with
      #   the details of the changes found in the repository or +nil+ if no
      #   changes were found.
      def verify_changes
        Dragnet::Verifiers::ChangesVerifier
          .new(test_record: test_record, repository: repository, test_records: test_records).verify
      end
    end
  end
end
