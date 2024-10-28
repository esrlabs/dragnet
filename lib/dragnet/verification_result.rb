# frozen_string_literal: true

require 'colorize'

require_relative 'errors/missing_timestamp_attribute_error'

module Dragnet
  # Holds the verification result of a Manual Test Record
  class VerificationResult
    VALID_STATUSES = %i[passed skipped failed].freeze

    attr_reader :status, :reason, :started_at, :finished_at

    # Creates a new instance of the class.
    # @param [Symbol] status The status
    # @param [String] reason
    def initialize(status:, reason: nil)
      self.status = status
      @reason = reason
    end

    def passed?
      status == :passed
    end

    def skipped?
      status == :skipped
    end

    def failed?
      status == :failed
    end

    # Assigns the given status
    # @param [Symbol] status The status
    # @raise [ArgumentError] If the given status is not one of the accepted
    #   valid statuses.
    def status=(status)
      unless VALID_STATUSES.include?(status)
        raise ArgumentError, "Invalid status #{status}."\
              " Valid statuses are: #{VALID_STATUSES.join(', ')}"
      end

      @status = status
    end

    # Sets the verification's start time.
    # @param [Time] time The verification's start time.
    # @raise [ArgumentError] If the given +time+ is not an instance of +Time+.
    # @raise [ArgumentError] If +finished_at+ is set and the given +time+ is
    #   bigger than or equal to it.
    def started_at=(time)
      validate_time(time)
      raise ArgumentError, 'started_at must be smaller than finished_at' if finished_at && time >= finished_at

      @runtime = nil
      @started_at = time
    end

    # Sets the verification's finish time
    # @param [Time] time The verification's finish time.
    # @raise [TypeError] Is an attempt is made to set +finished_at+ before
    #   setting +started_at+.
    # @raise [ArgumentError] If the given +time+ is not an instance of +Time+.
    # @raise [ArgumentError] If +started_at+ is set and the given +time+ is
    #   smaller than or equal to it.
    def finished_at=(time)
      validate_time(time)
      raise ArgumentError, 'finished_at must be greater than started_at' if started_at && time <= started_at

      @runtime = nil
      @finished_at = time
    end

    # @return [Float, nil] The runtime calculated from the started_at and
    #   finished_at attributes, if any of them is missing +nil+ is returned
    #   instead.
    def runtime
      runtime!
    rescue Dragnet::Errors::MissingTimestampAttributeError
      nil
    end

    # @return [Float] The runtime calculated from the started_at and finished_at
    #   timestamp attributes.
    # @raise [TypeError] If either of these attributes is +nil+
    def runtime!
      @runtime ||= calculate_runtime
    end

    # @return [String] A string representation of the receiver that can be used
    #   to log the result of a verification.
    def log_message
      if passed?
        '✔ PASSED '.colorize(:light_green)
      elsif skipped?
        "#{'⚠ SKIPPED'.colorize(:light_yellow)} #{reason}"
      else
        "#{'✘ FAILED '.colorize(:light_red)} #{reason || 'Unknown reason'}"
      end
    end

    private

    # Checks if the given object is a +Time+ and raises an +ArgumentError+ if it
    # isn't.
    # @param [Object] time The object to check.
    # @raise [ArgumentError] If the given object is not a +Time+ object.
    def validate_time(time)
      raise ArgumentError, "Expected a Time object, got #{time.class}" unless time.is_a?(Time)
    end

    # @return [Float] The runtime calculated from the started_at and finished_at
    #   timestamp attributes.
    # @raise [TypeError] If either of these attributes is +nil+
    def calculate_runtime
      if started_at.nil? || finished_at.nil?
        raise Dragnet::Errors::MissingTimestampAttributeError,
              'Both started_at and finished_at must be set in order to calculate the runtime'
      end

      finished_at - started_at
    end
  end
end
