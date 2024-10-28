# frozen_string_literal: true

module Dragnet
  module Exporters
    module Serializers
      # Serializes a +VerificationResult+ object into a +Hash+.
      class VerificationResultSerializer
        attr_reader :verification_result

        # Format used to serialize the +VerificationResult+'s date/time attributes.
        DATE_FORMAT = '%F %T %z'

        # @param [Dragnet::VerificationResult] verification_result The
        #   +VerificationResult+ object to serialize.
        def initialize(verification_result)
          @verification_result = verification_result
        end

        # @return [Hash] The +Hash+ representation of the given
        #   +VerificationResult+ object.
        def serialize
          {
            status: verification_result.status,
            started_at: verification_result.started_at.strftime(DATE_FORMAT),
            finished_at: verification_result.finished_at.strftime(DATE_FORMAT),
            runtime: verification_result.runtime
          }.tap do |hash|
            hash[:reason] = verification_result.reason if verification_result.reason
          end
        end
      end
    end
  end
end
