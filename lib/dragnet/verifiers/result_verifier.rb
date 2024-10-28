# frozen_string_literal: true

require_relative 'verifier'
require_relative '../verification_result'

module Dragnet
  module Verifiers
    # Verifies the +result+ field on the given MTR record.
    class ResultVerifier < Dragnet::Verifiers::Verifier
      # Performs the verification. If the +result+ field contains the "failed"
      # text then a +result+ key will be added to the Test Record explaining
      # the reason for the failure.
      # @return [Dragnet::VerificationResult, nil] A +VerificationResult+ object
      #   when the verification fails and +nil+ when the verification passes.
      def verify
        return if test_record.passed?

        Dragnet::VerificationResult.new(
          status: :failed,
          reason: "'result' field has the status '#{result}'"
        )
      end

      private

      # @return [String] The value for the +result+ key on the MTR file.
      def result
        @result ||= test_record.result
      end
    end
  end
end
