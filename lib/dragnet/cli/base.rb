# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/hash'
require 'colorize'
require 'thor'
require 'yaml'

require_relative 'logger'

module Dragnet
  module CLI
    # Base class for all CLI classes.
    class Base < Thor
      include Thor::Actions

      # Exit status codes
      E_CONFIG_LOAD_ERROR = 1

      attr_reader :configuration, :logger

      class_option :configuration, aliases: :c, desc: 'Configuration file',
                                   default: '.dragnet.yaml', required: true

      class_option :quiet, aliases: :q, default: false, type: :boolean,
                           desc: 'Suppresses all terminal output (except for critical errors)'

      # Tells Thor to return an unsuccessful return code (different from 0) if
      # an error is raised.
      def self.exit_on_failure?
        true
      end

      # Creates a new instance of the class. Called by Thor when a command is
      # executed. Creates a logger for the class passing Thor's shell to it
      # (Thor's shell handles the output to the console)
      def initialize(*args)
        super
        @logger = Dragnet::CLI::Logger.new(shell)
      end

      private

      # @return [String] Returns the name of the configuration file (passed via
      #   the -c command line switch).
      def configuration_file
        @configuration_file ||= options[:configuration]
      end

      # Loads the configuration from the given configuration file. (This is a
      # dumb loader, it basically loads the whole YAML file into a hash, no
      # parsing, validation or checking takes place)
      def load_configuration
        logger.info "Loading configuration file #{configuration_file}..."
        @configuration = YAML.safe_load(File.read(configuration_file)).deep_symbolize_keys
      rescue StandardError => e
        fatal_error("Unable to load the given configuration file: '#{configuration_file}'", e, E_CONFIG_LOAD_ERROR)
      end

      # Prints the given message alongside the message of the given exception
      # and then terminates the process with the given exit code.
      # @param [String] message The error message.
      # @param [Exception] exception The exception that caused the fatal error.
      # @param [exit_code] exit_code The exit code.
      def fatal_error(message, exception, exit_code)
        puts 'Error: '.colorize(:light_red) + message
        puts "       #{exception.message}"
        exit(exit_code)
      end
    end
  end
end
