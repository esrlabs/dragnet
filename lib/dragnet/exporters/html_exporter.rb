# frozen_string_literal: true

require 'erb'

require_relative '../helpers/repository_helper'
require_relative 'exporter'

module Dragnet
  module Exporters
    # Creates an HTML report from the given Test Records and Errors data.
    class HTMLExporter < Dragnet::Exporters::Exporter
      include Dragnet::Helpers::RepositoryHelper

      TEMPLATE = File.join(__dir__, 'templates', 'template.html.erb').freeze

      # Generates the report and returns it as a string.
      # @return [String] The generated HTML report.
      def export
        logger.info "Generating HTML report from template: #{TEMPLATE}..."
        ERB.new(File.read(TEMPLATE)).result(binding)
      end

      private

      # Returns the percentage that +num1+ represents with respect to +num2+
      # @param [Integer, Float] num1 A number.
      # @param [Integer, Float] num2 A number.
      # @return [Integer, Float] The percentage that +num1+ represents with
      #   respect to +num2+ rounded to two decimal places.
      def percentage(num1, num2)
        return 0.0 if num1.zero? || num2.zero?

        ((num1.to_f / num2) * 100).round(2)
      end

      # @param [Dragnet::Repository] repository The repository whose branches
      #   should be retrieved.
      # @return [Array<String>] An array with the names of the branches that
      #   "contain" the current head of the repository (may be empty).
      def software_branches(repository)
        # (uniq needed because of remote/local branches)
        repository.branches_with_head.map(&:name).uniq
      rescue Git::GitExecuteError => e
        logger.warn "Failed to read branches information from the repository at #{repository.path}"
        logger.warn e.message
        []
      end

      # Method used to memoize the output of the +group_by_requirement+ method.
      # @see #group_by_requirement
      # @return [Hash] A hash whose keys are the requirement IDs and whose
      #   values are arrays of MTRs
      def test_records_by_requirement
        @test_records_by_requirement ||= group_by_requirement
      end

      # Groups the MTRs by the requirement(s) they are covering, if a MTR covers
      # more than one requirement it will be added to all of them, if a
      # requirement is covered by more than one MTR the requirement will end up
      # with more than one MTR, example:
      #
      # {
      #   'ESR_REQ_9675' => [MTR1],
      #   'ESR_REQ_1879' => [MTR2, MTR3]
      #   'ESR_REQ_4714' => [MTR3]
      # }
      #
      # @return [Hash] A hash whose keys are the requirement IDs and whose
      #   values are arrays of MTRs
      def group_by_requirement
        tests_by_requirement = {}

        test_records.each do |test_record|
          ids = *test_record.id
          ids.each do |id|
            tests_by_requirement[id] ||= []
            tests_by_requirement[id] << test_record
          end
        end

        tests_by_requirement
      end

      # Returns the HTML code needed to render the Review Status of a MTR as a
      # badge.
      # @param [Dragnet::TestRecord] test_record The Test Record.
      # @return [String] The HTML code to display the Test Record's review
      #   status as a badge.
      def review_status_badge(test_record)
        if test_record.review_status
          color = test_record.reviewed? ? 'green' : 'red'
          review_status = test_record.review_status.capitalize
        else
          color = 'gray'
          review_status = '(unknown)'
        end

        badge_html(color, review_status)
      end

      # Returns the HTML code needed to display the verification result of a MTR
      # (the color and the text inside the badge are picked in accordance to the
      # given result).
      # @param [Dragnet::VerificationResult] verification_result The result of
      #   the verification for a given +TestRecord+
      # @return [String] The HTML code needed to display the result as a badge.
      def verification_result_badge(verification_result)
        badge_html(
          verification_result_color(verification_result),
          verification_result.status.capitalize
        )
      end

      # Returns a color that depends on the verification result for a Test
      # Record. To be used on HTML elements.
      # @param [Dragnet::VerificationResult] verification_result The
      #   +VerificationResult+ object.
      # @return [String] The corresponding color (depends on the +status+ field
      #   of the +VerificationResult+ object).
      def verification_result_color(verification_result)
        case verification_result.status
        when :passed
          'green'
        when :skipped
          'yellow'
        else
          'red'
        end
      end

      # Returns the color that should be used for the highlight line on the left
      # of the card given the result of the MTR's verification.
      # @param [Dragnet::VerificationResult] verification_result The
      #   +VerificationResult+ object associated with the +TestRecord+ being
      #   rendered on the card.
      def card_color(verification_result)
        verification_result_color(verification_result)
      end

      # Returns the HTML string to produce a Badge
      # @param [String] color The color of the badge.
      # @param [String] text The text that goes inside the badge.
      # @return [String] The HTML code to produce a badge with the given color
      #   and text.
      def badge_html(color, text)
        "<span class=\"badge bg-#{color}\">#{text}</span>"
      end

      # Converts the ID (+String+) or IDs (+Array<String>+) of a +TestRecord+
      # object into a string that can be safely rendered in the HTML report.
      # @param [Dragnet::TestRecord] test_record The +TestRecord+ object.
      # @return [String] A string with the ID or IDs of the +TestRecord+ object.
      def test_record_id_to_string(test_record)
        Array(test_record.id).join(', ')
      end
    end
  end
end
