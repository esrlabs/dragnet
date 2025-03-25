# frozen_string_literal: true

require_relative '../explorer'
require_relative '../exporter'
require_relative '../multi_repository'
require_relative '../repository'
require_relative '../validator'
require_relative '../verifier'
require_relative '../version'
require_relative 'base'

module Dragnet
  module CLI
    # Entry point class for the Dragnet CLI. Includes all the commands and
    # sub-commands of the CLI.
    #
    # The class should not contain any logic, everything should be delegated to
    # helper classes as soon as possible. Only exceptions are error handling and
    # message printing.
    class Master < Dragnet::CLI::Base
      E_MISSING_PARAMETER_ERROR = 2
      E_NO_MTR_FILES_FOUND = 3
      E_GIT_ERROR = 4
      E_EXPORT_ERROR = 5
      E_INCOMPATIBLE_REPOSITORY = 6

      E_ERRORS_DETECTED = 16
      E_FAILED_TESTS = 32

      map %w[--version -v] => :version

      desc '--version', 'Prints the current version of the Gem'
      method_option :'number-only',
                    aliases: 'n', type: :boolean,
                    desc: 'If given, only the version number will be printed'
      def version
        if options[:'number-only']
          say Dragnet::VERSION
        else
          say "Dragnet #{Dragnet::VERSION}"
          say "Copyright (c) #{Time.now.year} ESR Labs GmbH esrlabs.com"
        end
      end

      desc 'check [PATH]', 'Executes the verification procedure. '\
           'Loads the given configuration file and executes the verify procedure on the given path '\
           '(defaults to the value of the "path" key in the configuration file or the current '\
           'working directory if none of them is given)'
      method_option :export,
                    aliases: 'e', type: :string, repeatable: true,
                    desc: 'If given, the results of the verification procedure will be exported to'\
                    ' the given file. The format of the export will be deducted from the given'\
                    " file's name"
      method_option :'multi-repo',
                    aliases: '-m', type: :boolean, default: false,
                    desc: 'Enables the multi-repo compatibility mode. This prevents Dragnet from assuming'\
                    ' that [PATH] refers to a Git repository allowing it to run even if that is not the case.'\
                    " Using this option will cause Dragnet to raise an error if it finds a MTR which doesn't"\
                    " have a 'repos' attribute"
      def check(path = nil)
        load_configuration
        self.path = path

        files = explore
        test_records, errors = validate(files)
        verify(test_records)

        export(test_records, errors) if options[:export]

        exit_code = 0
        exit_code |= E_ERRORS_DETECTED if errors.any?
        exit_code |= E_FAILED_TESTS unless test_records.all? { |test_record| test_record.verification_result.passed? }

        exit(exit_code) if exit_code.positive? # doing exit(0) will stop RSpec execution.
      end

      private

      # Runs the explorer on the given path.
      # @return [Array<Pathname>] The array of found MTR files.
      def explore
        glob_patterns = configuration[:glob_patterns]

        begin
          explorer = Dragnet::Explorer.new(path: path, glob_patterns: glob_patterns, logger: logger)
          explorer.files
        rescue ArgumentError => e
          fatal_error('Initialization error. Missing or malformed parameter.', e, E_MISSING_PARAMETER_ERROR)
        rescue Dragnet::Errors::NoMTRFilesFoundError => e
          fatal_error('No MTR Files found.', e, E_NO_MTR_FILES_FOUND)
        end
      end

      # Executes the validator on the given MTR files.
      # @param [Array<Pathname>] files The files to run the validator on.
      # @return [Array (Array<Dragnet::TestRecord>, Array<Hash>)] An array.
      #   - The first element is an array of +TestRecord+s with the MTR data.
      #     One for each valid MTR file.
      #   - The second element contains the errors occurred during the
      #     validation process. Can be an empty array.
      def validate(files)
        validator = Dragnet::Validator.new(files: files, path: path, logger: logger)
        [validator.validate, validator.errors]
      end

      # Executes the verification on the given MTRs
      # @param [Array<Dragnet::TestRecord>] test_records The array of MTRs on
      #   which the verification should be executed.
      def verify(test_records)
        verifier = Dragnet::Verifier.new(test_records: test_records, repository: repository, logger: logger)
        verifier.verify
      rescue ArgumentError => e
        fatal_error("Could not open the specified path: #{path} as a Git Repository", e, E_GIT_ERROR)
      rescue Dragnet::Errors::IncompatibleRepositoryError => e
        incompatible_repository_error(e)
      end

      # Executes the export process.
      # @param [Array<Dragnet::TestRecord>] test_records The validated and
      #   verified test records.
      # @param [Array<Hashes>] errors The array of Hashes with the MTR files
      #   that didn't pass the validation process.
      def export(test_records, errors)
        exporter = Dragnet::Exporter.new(
          test_records: test_records, errors: errors, repository: repository, targets: options[:export], logger: logger
        )

        exporter.export
      rescue Dragnet::Errors::UnknownExportFormatError, Dragnet::Errors::UnableToWriteReportError => e
        fatal_error('Export failed', e, E_EXPORT_ERROR)
      rescue Dragnet::Errors::IncompatibleRepositoryError => e
        incompatible_repository_error(e)
      end

      # @return [Pathname] The path of the directory where the verification
      #   process should be executed.
      def path
        @path || set_fallback_path
      end

      # @param [Pathname, String] path The path of the directory where the
      #   verification process should be executed.
      def path=(path)
        @path = path ? Pathname.new(path) : nil
      end

      # @raise [ArgumentError] If the given path is not a valid git repository.
      # @return [Dragnet::Repository, Dragnet::MultiRepository] One of the
      #   possible Repository objects.
      def repository
        @repository ||= create_repository
      end

      # Creates the appropriate Repository object in accordance to the status of
      # the +multi-repo+ command line option.
      # @return [Dragnet::MultiRepository] If +multi-repo+ was set to +true+
      # @return [Dragnet::Repository] If +multi_repo+ was set to +false+
      def create_repository
        options[:'multi-repo'] ? Dragnet::MultiRepository.new(path: path) : Dragnet::Repository.new(path: path)
      end

      # Prints a message and exits with the proper error code when a
      # +Dragnet::Errors::IncompatibleRepositoryError+ is raised.
      # @param [Dragnet::Errors::IncompatibleRepositoryError] error The raised
      #   error.
      def incompatible_repository_error(error)
        fatal_error('Incompatible git operation:', error, E_INCOMPATIBLE_REPOSITORY)
      end

      # Called when no path has been given by the user explicitly. The method
      # uses the configured path or the current working directory as a fallback.
      # @return [Pathname] The constructed fallback path.
      def set_fallback_path
        # The && causes Ruby to return the value of +@path+ AFTER it has been
        # assigned (converted to a Pathname)
        (self.path = configuration[:path] || Dir.pwd) && @path
      end
    end
  end
end
