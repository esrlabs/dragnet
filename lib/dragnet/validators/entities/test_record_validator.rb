# frozen_string_literal: true

require_relative '../fields/description_validator'
require_relative '../fields/files_validator'
require_relative '../fields/id_validator'
require_relative '../fields/meta_data_field_validator'
require_relative '../fields/repos_validator'
require_relative '../fields/result_validator'
require_relative '../fields/sha1_validator'

require_relative '../../errors/validation_error'

module Dragnet
  module Validators
    module Entities
      # Validates a MTR object
      class TestRecordValidator
        attr_reader :test_record

        # Creates a new instance of the class.
        # @param [Dragnet::TestRecord] test_record The test record to validate.
        def initialize(test_record)
          @test_record = test_record
        end

        # Validates the given test record
        # @raise [Dragnet::Errors::ValidationError] If the validation fails.
        def validate
          repos_xor_files
          repos_xor_sha1

          Dragnet::Validators::Fields::IDValidator.new.validate('id', test_record.id)
          Dragnet::Validators::Fields::DescriptionValidator.new.validate('description', test_record.description)
          validate_meta_data_fields

          test_record.files = Dragnet::Validators::Fields::FilesValidator.new.validate('files', test_record.files)
          test_record.result = Dragnet::Validators::Fields::ResultValidator.new.validate('result', test_record.result)
        end

        private

        # @raise [Dragnet::Errors::ValidationError] If the MTR has both a
        #   +files+ and a +repos+ attribute.
        def repos_xor_files
          return unless test_record.files && test_record.repos

          raise Dragnet::Errors::ValidationError,
                "Invalid MTR: #{test_record.id}. Either 'files' or 'repos' should be provided, not both"
        end

        # Executes the validation over the +repos+ attribute and then verifies
        # if the +sha1+ attribute was also given. If it was, an error is
        # raised. If +repos+ is not present, then the +sha1+ attribute is
        # validated.
        #
        # This happens in this order to leverage the fact that the
        # +ReposValidator+ returns +nil+ for empty +Array+s. So if +repos+ is
        # given as en empty +Array+ the MTR will still be considered valid
        # (provided it has a SHA1).
        #
        # @raise [Dragnet::Errors::ValidationError] If the validation of the
        #   +repos+ attribute fails, if both +repos+ and +sha1+ are present or
        #   if the validation of the +sha1+ attribute fails.
        def repos_xor_sha1
          test_record.repos = Dragnet::Validators::Fields::ReposValidator.new.validate('repos', test_record.repos)

          unless test_record.repos
            Dragnet::Validators::Fields::SHA1Validator.new.validate('sha1', test_record.sha1)
            return
          end

          return unless test_record.sha1

          raise Dragnet::Errors::ValidationError,
                "Invalid MTR: #{test_record.id}. Either 'repos' or 'sha1' should be provided, not both"
        end

        # Validates the meta-data fields of the Test Record.
        # @raise [Dragnet::Errors::ValidationError] If any of the meta-data
        #   fields fail the validation.
        def validate_meta_data_fields
          meta_data_validator = Dragnet::Validators::Fields::MetaDataFieldValidator.new

          test_record.name = meta_data_validator.validate('name', test_record.name)
          test_record.test_method = meta_data_validator.validate('test_method', test_record.test_method)
          test_record.tc_derivation_method = meta_data_validator.validate(
            'tc_derivation_method', test_record.tc_derivation_method
          )
        end
      end
    end
  end
end
