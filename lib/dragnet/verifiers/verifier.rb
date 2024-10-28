# frozen_string_literal: true

require_relative '../helpers/repository_helper'

module Dragnet
  module Verifiers
    # Base class for all validators.
    class Verifier
      include Dragnet::Helpers::RepositoryHelper

      attr_reader :test_record

      # Creates a new instance of the class.
      # @param [Dragnet::TestRecord] test_record The +TestRecord+ object to
      #   verify.
      def initialize(test_record:)
        @test_record = test_record
      end

      # Needs to be implemented by the child classes. This method is called to
      # perform the verification on the given +test_record+.
      # @return [Dragnet::VerificationResult, nil] The method should return a
      #   +VerificationResult+ object if the verification fails or +nil+ if it
      #   passes.
      def verify
        raise NotImplementedError, "Please implement #{__method__} in #{self.class}"
      end

      private

      # @return [String] The SHA1 stored in the MTR File.
      def sha1
        @sha1 ||= test_record.sha1
      end
    end
  end
end
