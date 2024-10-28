# frozen_string_literal: true

require_relative 'verifier'

module Dragnet
  module Verifiers
    # Base class for the Verifiers that need access to the repository to perform
    # the validation.
    class RepositoryVerifier < Dragnet::Verifiers::Verifier
      attr_reader :repository

      # @param [Dragnet::Repository] repository A +Dragnet::Repository+ object
      #   linked to the repository where the sources and MTR files are located
      def initialize(test_record:, repository:)
        super(test_record: test_record)
        @repository = repository
      end

      private

      # @return [String] The path to the repository.
      def path
        @path ||= repository.path
      end
    end
  end
end
