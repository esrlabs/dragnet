# frozen_string_literal: true

require 'digest'

require_relative '../helpers/repository_helper'

module Dragnet
  module Exporters
    # Generates unique IDs for the Manual Test Records by hashing some of their
    # properties into a hexadecimal SHA1.
    class IDGenerator
      include Dragnet::Helpers::RepositoryHelper

      attr_reader :test_record, :repository

      # @param [Dragnet::TestRecord] test_record The record for which the IDs
      #   should be calculated.
      # @param [Dragnet::Repository] repository The repository where the MTR
      #   files are located. This allows the SHA1 to be calculated with relative
      #   paths to the MTRs' files.
      def initialize(test_record, repository)
        @test_record = test_record
        @repository = repository
      end

      # @return [String] The MTR's Long ID
      def long_id
        @long_id ||= "#{relative_to_repo(test_record.source_file)}#{test_record.id}"
      end

      # @return [String] The MTR's Short ID
      def short_id
        # noinspection RubyMismatchedReturnType (This is never nil)
        Digest::SHA1.hexdigest(long_id)[0...16]
      end
    end
  end
end
