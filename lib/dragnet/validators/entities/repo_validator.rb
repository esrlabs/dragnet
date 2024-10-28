# frozen_string_literal: true

require_relative '../fields/sha1_validator'
require_relative '../fields/files_validator'
require_relative '../fields/path_validator'

module Dragnet
  module Validators
    module Entities
      # Validates a +Dragnet::Repo+ object, by checking its attributes.
      class RepoValidator
        attr_reader :repo

        # @param [Dragnet::Repo] repo An instance of +Dragnet::Repo+ to validate.
        def initialize(repo)
          @repo = repo
        end

        # Validates the instance of the +Dragnet::Repo+ object by checking each
        # of its attributes.
        # @raise [Dragnet::Errors::ValidationError] If any of the fields in the
        #   given +Dragnet::Repo+ object fails the validation.
        def validate
          Dragnet::Validators::Fields::SHA1Validator.new.validate('repos[sha1]', repo.sha1)
          Dragnet::Validators::Fields::PathValidator.new.validate('repos[path]', repo.path)
          repo.files = Dragnet::Validators::Fields::FilesValidator.new.validate('repos[files]', repo.files)
        end
      end
    end
  end
end
