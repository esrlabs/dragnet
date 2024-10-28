# frozen_string_literal: true

require 'digest'

require_relative '../helpers/repository_helper'

module Dragnet
  module Exporters
    # Generates unique IDs for the Manual Test Records by hashing some of their
    # properties into a hexadecimal SHA1.
    class IDGenerator
      include Dragnet::Helpers::RepositoryHelper

      attr_reader :repository

      # @param [Dragnet::Repository] repository The repository where the MTR
      #   files are located. This allows the SHA1 to be calculated with relative
      #   paths to the MTRs' files.
      def initialize(repository)
        @repository = repository
      end

      # Calculates the ID of the given MTR
      # @param [Dragnet::TestRecord] test_record The record for which the ID
      #   should be calculated.
      # @return [String] The ID for the given +TestRecord+.
      # :reek:FeatureEnvy (Cannot be done in the TestRecord itself because it needs the Repository)
      def id_for(test_record)
        string = "#{relative_to_repo(test_record.source_file)}#{test_record.id}"
        # noinspection RubyMismatchedReturnType (This is never nil)
        Digest::SHA1.hexdigest(string)[0...16]
      end
    end
  end
end
