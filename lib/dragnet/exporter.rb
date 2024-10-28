# frozen_string_literal: true

require_relative 'errors/unable_to_write_report_error'
require_relative 'errors/unknown_export_format_error'
require_relative 'exporters/html_exporter'
require_relative 'exporters/json_exporter'

module Dragnet
  # The base exporter class, receives an array of test records, an array of
  # errors and an array of file names and exports the results to the given
  # files. (For each file the format is deduced from its file name).
  class Exporter
    KNOWN_FORMATS = {
      'HTML' => { extensions: %w[.html .htm], exporter: Dragnet::Exporters::HTMLExporter },
      'JSON' => { extensions: %w[.json], exporter: Dragnet::Exporters::JSONExporter }
    }.freeze

    attr_reader :test_records, :errors, :repository, :targets, :logger

    # Creates a new instance of the class.
    # @param [Array<Dragnet::TestRecord>] test_records The array of MTRs that
    #   should be included in the reports.
    # @param [Array<Hash>] errors An array of Hashes with the data of the MTR
    #   files that did not pass the validation process.
    # @param [Dragnet::Repository, Dragnet::MultiRepository] repository The
    #   repository where the MTR files and the source code are stored.
    # @param [Array<String>] targets The array of target files. For each of them
    #   the format of the export will be deduced from the file's extension.
    # @param [#info, #debug] logger A logger object to use for output.
    def initialize(test_records:, errors:, repository:, targets:, logger:)
      @test_records = test_records
      @errors = errors
      @repository = repository
      @targets = targets
      @logger = logger
    end

    # Starts the export process.
    # @raise [Dragnet::Errors::UnableToWriteReportError] If one of the target
    #   files cannot be created, opened, or if the output cannot be written to
    #   it.
    def export
      logger.info 'Starting export process...'
      log_target_files

      formats.each do |format, targets|
        exporter = KNOWN_FORMATS.dig(format, :exporter).new(
          test_records: test_records, errors: errors, repository: repository, logger: logger
        )

        text = exporter.export
        write_output(text, format, targets)
      end
    end

    private

    # Writes the given text output with the given format to the given targets.
    # @param [String] text The text output to write.
    # @param [String] format The format of the target file.
    # @param [Array<String>] targets The paths of the target files the output
    #   should be written to.
    # @raise [Dragnet::Errors::UnableToWriteReportError] If one of the target
    #   files cannot be created, opened, or if the output cannot be written to
    #   it.
    def write_output(text, format, targets)
      targets.each do |target|
        logger.info "Writing #{format} output to #{target}..."

        begin
          start = Time.now
          bytes = File.write(target, text)
          elapsed = Time.now - start

          logger.debug("Ok (#{bytes} bytes written in #{elapsed} seconds)")
        rescue SystemCallError => e
          raise Dragnet::Errors::UnableToWriteReportError,
                "Unable to write report output to #{target}: #{e.message}"
        end
      end
    end

    # Writes a log entry with the files that will be written as a result of the
    # export process (each with its corresponding format).
    def log_target_files
      files_with_formats = formats.flat_map do |format, targets|
        targets.map { |target| "\t * #{target} as #{format}" }
      end

      logger.debug "Target files are:\n#{files_with_formats.join("\n")}"
    end

    # @return [Hash] A hash whose keys are known formats and whose values are
    #   arrays of target files.
    def formats
      @formats ||= deduce_formats
    end

    # Deduces the format of each target file (given its extension) and relates
    # them to their corresponding formats.
    # @return [Hash] A hash whose keys are known formats and whose values are
    #   arrays of target files.
    def deduce_formats
      formats = {}

      targets.each do |target|
        extension = File.extname(target).downcase
        format, = KNOWN_FORMATS.find { |_name, config| config[:extensions].include?(extension) }
        unknown_format_error(extension) unless format

        formats[format] ||= []
        formats[format] << target
      end

      formats
    end

    # Raises a +Dragnet::Errors::UnknownExportFormatError+ with the proper error
    # message.
    # @param [String] extension The extension of the given target file.
    # @raise [Dragnet::Errors::UnknownExportFormatError] is always raised.
    def unknown_format_error(extension)
      allowed_extensions = KNOWN_FORMATS.flat_map { |_format, config| config[:extensions] }

      raise Dragnet::Errors::UnknownExportFormatError,
            "Unknown export format: '#{extension}'. Valid export formats are: "\
            "#{allowed_extensions.join(', ')}"
    end
  end
end
