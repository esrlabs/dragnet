# frozen_string_literal: true

require_relative '../errors/file_not_found_error'
require_relative 'validator'

module Dragnet
  module Validators
    # Validates the +files+ key in the given Manual Test Record object.
    # Validates:
    #   - That the listed file(s) glob pattern(s) match at least one file in the
    #     repository.
    class FilesValidator < Dragnet::Validators::Validator
      attr_reader :test_record, :path

      # Creates a new instance of the class.
      # @param [Dragnet::TestRecord] test_record The +TestRecord+ object whose
      #   files should be validated.
      # @param [Pathname] path The path to the repository where the files are
      #   supposed to be located.
      def initialize(test_record, path)
        @test_record = test_record
        @files = test_record.files
        @path = path
      end

      # Validates the +files+ key in the given data.
      # Updates the +file+ key in the given +data+ to the actual files found in
      # the repository.
      # @raise [Dragnet::Errors::FileNotFoundError] If any of the listed files
      #   cannot be found in the given repository path or if a glob pattern
      #   doesn't match any files there.
      def validate
        return unless files

        test_record.files = translate_paths && force_relative_paths && resolve_files
      end

      private

      attr_reader :files

      # Forces all the file paths to be relative by removing the +/+ at the
      # start (if they have one). This is done to ensure that files are always
      # considered relative to the path being checked.
      def force_relative_paths
        @files = files.map do |file|
          file.sub(%r{^/}, '')
        end
      end

      # Translate the file paths from windows style paths (with \ as path
      # separator) to Unix style paths (with / as path separator).
      # This is done so that the git commands work in all systems.
      def translate_paths
        @files = files.map do |file|
          file.tr('\\', '/')
        end
      end

      # Resolve the given files by checking for matches in the given repository.
      # Glob patterns are resolved an translated into individual files.
      # @return [Array<Pathname>] The resolved file paths.
      # @raise [Dragnet::Errors::FileNotFoundError] If any of the listed files
      #   cannot be found in the given repository path or if a glob pattern
      #   doesn't match any files there.
      def resolve_files
        resolved_files = []

        files.each do |file|
          # Files can be defined as glob patterns
          matched_files = path.glob(file)

          if matched_files.empty?
            raise Dragnet::Errors::FileNotFoundError,
                  "Could not find any files matching #{file} in #{path}"
          end

          resolved_files += matched_files
        end

        resolved_files
      end
    end
  end
end
