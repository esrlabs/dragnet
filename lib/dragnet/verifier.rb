# frozen_string_literal: true

require 'git'

require_relative 'verifiers/test_record_verifier'

module Dragnet
  # Executes the verification process on the given Test Records
  class Verifier
    attr_reader :test_records, :path, :logger

    # Creates a new instance of the class.
    # @param [Array<Hash>] test_records An array with the test records.
    # @param [Dragnet::Repository] repository The repository where the MTR and
    #   the source files are stored.
    # @param [#info] logger The logger object to use for output.
    def initialize(test_records:, repository:, logger:)
      @test_records = test_records
      @repository = repository
      @logger = logger
    end

    # Runs the verify process
    # After the execution of this method each Test Record will get a +:result+
    # key with the result of the verification process. This key contains a hash
    # like the following:
    #
    #  result: {
    #    status: :passed,     # Either :passed, :failed or :skipped
    #    reason: 'String'     # The reason for the failure (for :failed and :skipped)
    #  }
    def verify
      logger.info 'Verifying MTR files...'
      test_records.each do |test_record|
        logger.info "Verifying #{test_record.source_file}"
        verify_mtr(test_record)
      end
    end

    private

    attr_reader :repository

    # Verifies the given Manual Test Record
    # Runs the given test record through all the verifiers. If no verifier adds
    # a +result+ key to the Test Record then the method adds one with passed
    # status.
    # @param [Dragnet::TestRecord] test_record The Test Record to verify.
    def verify_mtr(test_record)
      started_at = Time.now.utc

      verification_result = Dragnet::Verifiers::TestRecordVerifier.new(
        test_record: test_record, repository: repository, test_records: test_records
      ).verify

      finished_at = Time.now.utc
      verification_result.started_at = started_at
      verification_result.finished_at = finished_at
      test_record.verification_result = verification_result

      logger.info(verification_result.log_message)
    end
  end
end
