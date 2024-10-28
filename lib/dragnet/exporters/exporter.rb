# frozen_string_literal: true

module Dragnet
  module Exporters
    # Base class for all exporter classes.
    class Exporter
      attr_reader :test_records, :errors, :repository, :logger

      # @param [Array<Hash>] test_records The array of test records.
      # @param [Array<Hash>] errors The array of errors.
      # @param [Dragnet::Repository, Dragnet::MultiRepository] repository The
      #   repository where the MTR files and the source code are stored.
      # @param [#info] logger A logger object to use for output.
      def initialize(test_records:, errors:, repository:, logger:)
        @test_records = test_records
        @errors = errors
        @repository = repository
        @logger = logger
      end

      # @raise [NotImplementedError] Is always raised. Subclasses are expected
      #   to override this method.
      def export
        raise NotImplementedError,
              "'export' method not implemented for class #{self.class}"
      end
    end
  end
end
