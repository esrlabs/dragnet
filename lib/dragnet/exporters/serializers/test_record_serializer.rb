# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'

require_relative '../../helpers/repository_helper'
require_relative 'repo_serializer'
require_relative 'verification_result_serializer'

module Dragnet
  module Exporters
    module Serializers
      # Serializes a +TestRecord+ object into a +Hash+.
      class TestRecordSerializer
        include ::Dragnet::Helpers::RepositoryHelper

        attr_reader :test_record, :repository

        # @param [Dragnet::TestRecord] test_record The +TestRecord+ object to
        #   serialize.
        # @param [Dragnet::RepositoryBase] repository The +Repository+ object
        #   associated with the +TestRecord+. Used to render file paths relative
        #   to the repository instead of as absolute paths.
        def initialize(test_record, repository)
          @test_record = test_record
          @repository = repository
        end

        # rubocop:disable Metrics/AbcSize (because of the Hash)
        # rubocop:disable Metrics/CyclomaticComplexity (because of the conditionals)
        # rubocop:disable Metrics/PerceivedComplexity (because of the conditionals)
        # rubocop:disable Metrics/MethodLength (because of he Hash)

        # @return [Hash] A +Hash+ representing the given +TestRecord+ object.
        def serialize
          {
            refs: Array(test_record.id),
            result: test_record.result,
            review_status: render_review_status,
            verification_result: serialized_verification_result,

            # TODO: Remove the started_at and finished_at attributes after solving
            #   https://esrlabs.atlassian.net/browse/JAY-493
            started_at: serialized_verification_result[:started_at],
            finished_at: serialized_verification_result[:finished_at]
          }.tap do |hash|
            hash[:sha1] = test_record.sha1 if test_record.sha1.present?
            hash[:owner] = Array(test_record.name).join(', ') if test_record.name.present?
            hash[:description] = test_record.description if test_record.description.present?
            hash[:test_method] = Array(test_record.test_method) if test_record.test_method.present?

            if test_record.tc_derivation_method.present?
              hash[:tc_derivation_method] = Array(test_record.tc_derivation_method)
            end

            hash[:review_comments] = test_record.review_comments if test_record.review_comments.present?
            hash[:findings] = test_record.findings if test_record.findings?
            hash[:files] = serialize_files if test_record.files.present?
            hash[:repos] = serialize_repos if test_record.repos.present?
          end
        end

        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/MethodLength

        private

        # Renders the +TestRecord+'s review status
        # @return [String] The review status, either +'not_reviewed'+ or +'reviewed'+
        def render_review_status
          "#{test_record.reviewed? ? nil : 'not_'}reviewed"
        end

        # Serializes the files listed in the given +TestRecord+
        # @return [Array<String>] An array of strings, one for each listed file.
        def serialize_files
          test_record.files.map { |file| relative_to_repo(file).to_s }
        end

        # Serializes the +Repo+ objects attached to the +TestRecord+
        # @return [Array<Hash>] An array of +Hash+es representing each of the
        #   +Repo+ objects associated with the +TestRecord+
        def serialize_repos
          test_record.repos.map { |repo| ::Dragnet::Exporters::Serializers::RepoSerializer.new(repo).serialize }
        end

        # Serializes the +VerificationResult+ object attached to the given
        # +TestRecord+
        # @return [Hash] A +Hash+ representation of the +VerificationResult+
        #   object.
        def serialized_verification_result
          @serialized_verification_result ||= ::Dragnet::Exporters::Serializers::VerificationResultSerializer.new(
            test_record.verification_result
          ).serialize
        end
      end
    end
  end
end
