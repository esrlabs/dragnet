# frozen_string_literal: true

require_relative 'validators/entities/test_record_validator'

module Dragnet
  # Represents a Manual Test Record loaded from a MTR file.
  class TestRecord
    PASSED_RESULT = 'passed'
    REVIEWED_STATUS = 'reviewed'
    NO_FINDINGS = 'no findings'

    # :reek:Attribute (This is an entity class)

    attr_accessor :id, :result, :sha1, :name, :description, :files, :repos,
                  :review_status, :review_comments, :findings, :test_method,
                  :tc_derivation_method, :source_file, :verification_result

    # rubocop:disable Metrics/AbcSize (There isn't much that can be done here,
    #   those are the attributes an MTR has).
    # :reek:FeatureEnvy (Refers to args as much as it refers to itself)

    # Creates a new instance of the class.
    # @param [Hash] args The data for the Manual Test Record
    # @option args [String] :id The ID of the MTR
    # @option args [String] :result The result of the Manual Test.
    # @option args [String] :sha1 The SHA1 of the commit in which the Manual
    #   Test was performed.
    # @option args [String, Array<String>, nil] :name The name of the person who
    #   performed the Manual Test.
    # @option args [String, nil] :description The description of the Manual
    #   Test, normally which actions were performed and what it was mean to
    #   test.
    # @option args [String, Array<String>, nil] :files The files involved in the
    #   MTR, these are the files which will be checked for changes when
    #   evaluating the validity of the MTR.
    # @option args [Array<Hash>, nil] :repos An array of +Hash+es with the
    #   information about the repositories that are involved in the MTR, these
    #   repositories will be checked for changes during the evaluation of the
    #   MTR.
    # @option args [String, nil] :review_status or :reviewstatus The review
    #   status of the MTR. (Normally changed when someone other than the tester
    #   verifies the result of the Manual Test)
    # @option args [String, nil] :review_comments or :reviewcomments The
    #   comments left by the person who performed the review of the Manual Test.
    # @option args [String, nil] :findings The findings that the reviewer
    #   collected during the review process (if any).
    # @option args [String, Array<String>, nil] :test_method The method(s) used
    #   to carry out the test.
    # @option args [String, Array<String>, nil] :tc_derivation_method: The
    #   method(s) used to derive the test case,
    # @note Either +:files+ or +:repos+ should be present, not both.
    def initialize(args)
      @id = args[:id]
      @result = args[:result]
      @sha1 = args[:sha1]
      @name = args[:name]
      @description = args[:description]
      @files = args[:files]
      @repos = args[:repos]
      @review_status = args[:review_status] || args[:reviewstatus]
      @review_comments = args[:review_comments] || args[:reviewcomments]
      @findings = args[:findings]
      @test_method = args[:test_method]
      @tc_derivation_method = args[:tc_derivation_method]
    end
    # rubocop:enable Metrics/AbcSize

    # Validates the MTR's fields
    # @raise [Dragnet::Errors::ValidationError] If the validation fails.
    def validate
      Dragnet::Validators::Entities::TestRecordValidator.new(self).validate
    end

    # @return [Boolean] True if the Manual Test passed, false otherwise.
    def passed?
      result == PASSED_RESULT
    end

    # @return [Boolean] True if the Manual Test Record has been reviewed, false
    #   otherwise.
    def reviewed?
      review_status == REVIEWED_STATUS
    end

    # @return [Boolean] True if the Manual Test Record has findings (problems
    #   annotated during the review), false otherwise.
    def findings?
      !(findings.nil? || findings.strip.empty? || findings.downcase == NO_FINDINGS)
    end
  end
end
