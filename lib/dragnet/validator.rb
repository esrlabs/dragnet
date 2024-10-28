# frozen_string_literal: true

require 'colorize'

require_relative 'validators/data_validator'
require_relative 'validators/files_validator'
require_relative 'validators/repos_validator'

module Dragnet
  # Validates a set of Manual Test Record files. That means, checking that they
  # can be read, that they are valid YAML files, that they have the expected
  # keys and that these keys have sensible values.
  class Validator
    attr_reader :files, :path, :logger, :errors, :valid_files

    # Creates a new instance of the class.
    # @param [Array<Pathname>] files An array with the MTR files to validate.
    # @param [Pathname] path The path where the MTR files are located.
    # @param [#info, #error] logger A logger object to use for output.
    def initialize(files:, path:, logger:)
      @files = files
      @path = path
      @logger = logger
    end

    # Validates the given files.
    # @return [Array<Dragnet::TestRecord>] An array of +TestRecord+s, one for
    #   each valid MTR file (invalid files will be added to the +errors+ array).
    #   The returned hash has the following structure:
    def validate
      logger.info('Validating MTR Files...')

      @errors = []
      @valid_files = files.map { |file| validate_file(file) }.compact
    end

    private

    # Validates the given file
    # @param [Pathname] file The file to be validated.
    # @return [Dragnet::TestRecord, nil] A +TestRecord+ object or +nil+ if the
    #   file is invalid.
    # rubocop:disable Metrics/AbcSize (because of logging).
    def validate_file(file)
      logger.info "Validating #{file}..."
      data = YAML.safe_load(File.read(file))
      test_record = Dragnet::Validators::DataValidator.new(data, file).validate
      Dragnet::Validators::FilesValidator.new(test_record, path).validate
      Dragnet::Validators::ReposValidator.new(test_record, path).validate

      logger.info "#{'✔ SUCCESS'.colorize(:light_green)} #{file} Successfully loaded"
      test_record
    rescue SystemCallError => e
      push_error(file, 'IO Error: Cannot read the specified file', e)
    rescue Psych::Exception => e
      push_error(file, 'YAML Parsing Error', e)
    rescue Dragnet::Errors::YAMLFormatError => e
      push_error(file, 'YAML Formatting Error', e)
    rescue Dragnet::Errors::FileNotFoundError => e
      push_error(file, 'Referenced file not found in repository', e)
    rescue Dragnet::Errors::RepoPathNotFoundError => e
      push_error(file, 'Referenced repository not found', e)
    end
    # rubocop:enable Metrics/AbcSize

    # Pushes an entry into the +errors+ array.
    # @param [Pathname] file The file that contains the error.
    # @param [String] message A general description of the message.
    # @param [Exception] exception The raised exception (through which the file
    #   was branded invalid)
    # @return [nil] Returns nil so that +validate_file+ can return nil for
    #   invalid files.
    def push_error(file, message, exception)
      errors << { file: file, message: message, exception: exception }
      logger.error "#{'✘ FAILED'.colorize(:light_red)} #{file} Failed: #{message} - #{exception.message}"
      nil
    end
  end
end
