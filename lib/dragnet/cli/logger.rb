# frozen_string_literal: true

require 'colorize'

module Dragnet
  module CLI
    # A logger for the CLI. It uses the +say+ method in Thor's +Shell+ class to
    # print the messages to the output, honoring the status of the +quiet+
    # command line switch.
    class Logger
      attr_reader :shell, :log_level

      LEVELS = { debug: 0, info: 1, warn: 2, error: 3 }.freeze
      DEFAULT_LOG_LEVEL = :info
      PADDING_STRING = ' '
      PADDING_WIDTH = 7

      # Creates a new instance of the class.
      # @param [Thor::Shell::Basic] shell A reference to Thor's +Shell+ this
      #   will be used to send the output to the terminal in which Thor was
      #   started.
      # @param [Symbol] log_level The log level for the logger. The higher the
      #   level the less output will be printed.
      # @see LEVELS
      def initialize(shell, log_level = DEFAULT_LOG_LEVEL)
        raise ArgumentError, "Unknown logger level: #{log_level}" unless LEVELS.keys.include?(log_level)

        @log_level = LEVELS[log_level]
        @shell = shell
      end

      # Prints a message with log level +debug+
      # @param [String] message The message to print
      def debug(message)
        output(:debug, :green, message)
      end

      # Prints a message with log level +info+
      # @param [String] message The message to print
      def info(message)
        output(:info, :blue, message)
      end

      # Prints a message with log level +warn+
      # @param [String] message The message to print
      def warn(message)
        output(:warn, :yellow, message)
      end

      # Prints a message with log level +error+
      # @param [String] message The message to print
      def error(message)
        output(:error, :red, message)
      end

      private

      # Prints the given message with the given level and text color (only the
      # name of the level will be colored).
      # @param [Symbol] level The log level
      # @param [Symbol] color The color to use. One of the colors available for
      #   the +#colorize+ method.
      # @param [String] message The message to print.
      # @see Colorize::InstanceMethods#colorize
      def output(level, color, message)
        return unless log_level <= LEVELS[level]

        shell.say "#{level.to_s.capitalize}:".ljust(PADDING_WIDTH, PADDING_STRING).colorize(color) + message
      end
    end
  end
end
