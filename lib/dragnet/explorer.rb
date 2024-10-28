# frozen_string_literal: true

require_relative 'errors/no_mtr_files_found_error'

module Dragnet
  # This class searches for Manual Test Record files inside a given path by
  # using the given Glob patterns.
  class Explorer
    attr_reader :path, :glob_patterns, :logger

    # Creates a new instance of the class.
    # @param [Pathname] path The path that should be explored.
    # @param [String, Array<String>] glob_patterns The glob pattern or glob
    #   patterns to use when exploring the specified path.
    # @param [#info] logger A logger object to use for output.
    # @raise [ArgumentError] If +path+ or +glob_patterns+ are +nil+ or if they
    #   don't have one of the expected types.
    def initialize(path:, glob_patterns:, logger:)
      validate_path(path)
      validate_patterns(glob_patterns)

      @path = path
      @glob_patterns = *glob_patterns
      @logger = logger
    end

    # Performs the search for MTR files and returns an array with the found
    #   files.
    # @return [Array<Pathname>] The array of found MTR files.
    # @raise [Dragnet::Errors::NoMTRFilesFoundError] If no MTR files are found.
    def files
      @files ||= find_files
    end

    private

    # Raises an +ArgumentError+ with the appropriate message.
    # @param [String] name The name of the missing parameter.
    # @raise [ArgumentError] Is always raised with the appropriate message.
    def missing_parameter(name)
      raise ArgumentError, "Missing required parameter #{name}"
    end

    # Raises an +ArgumentError+ with the appropriate message.
    # @param [String] name The name of the parameter with an incompatible type.
    # @param [String, Class] expected The expected parameter type.
    # @param [String, Class] given The given parameter type.
    # @raise [ArgumentError] Is always raised with the appropriate message.
    def incompatible_parameter(name, expected, given)
      raise ArgumentError, "Incompatible parameter type #{name}. Expected: #{expected}, given: #{given}"
    end

    # Validates the given path
    # @param [Object] path The path to validate
    # @raise [ArgumentError] If the given path is nil or is not a +Pathname+.
    def validate_path(path)
      missing_parameter('path') unless path
      return if path.is_a?(Pathname)

      incompatible_parameter('path', Pathname, path.class)
    end

    # Validates the given glob patterns
    # @param [String, Array<String>] glob_patterns The glob patterns
    # @raise [ArgumentError] If +glob_patterns+ is +nil+ or it isn't an array
    #   of strings.
    def validate_patterns(glob_patterns)
      missing_parameter('glob_patterns') unless glob_patterns

      return if glob_patterns.is_a?(String)
      return if glob_patterns.is_a?(Array) && glob_patterns.all? { |value| value.is_a?(String) }

      incompatible_parameter('glob_patterns', 'String or Array<String>', glob_patterns.class)
    end

    # Logs the MTR files that were found.
    # @param [Array<Pathname>] files The found MTR files.
    # @return [Array<Pathname>] The same array given in +files+.
    def log_found_files(files)
      files.each { |file| logger.info("Found MTR file: #{file}") }
    end

    # Searches the +path+ for MTR files using the +glob_patterns+
    # @return [Array<Pathname>] The array of found MTR files.
    # @raise [Dragnet::Errors::NoMTRFilesFoundError] If no MTR files are found.
    def find_files
      logger.info 'Searching for Manual Test Records...'

      files = []

      glob_patterns.each do |glob_pattern|
        logger.info "Globbing #{path} with #{glob_pattern}..."

        files += log_found_files(path.glob(glob_pattern))
      end

      return files if files.any?

      raise Dragnet::Errors::NoMTRFilesFoundError,
            "No MTR Files found in #{path} with the following glob patterns: #{glob_patterns.join(', ')}"
    end
  end
end
