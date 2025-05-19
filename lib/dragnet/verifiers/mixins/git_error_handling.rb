# frozen_string_literal: true

module Dragnet
  module Verifiers
    module Mixins
      # A mixin that provides methods to gracefully handle errors during Git's
      # execution.
      module GitErrorHandling
        private

        # @param [Git::FailedError] error The error that occurred during the
        #   verification.
        # @return [Dragnet::VerificationResult] A +VerificationResult+ object that
        #   encapsulates the occurred error so that it can be presented to the
        #   user.
        def result_from_git_error(error)
          Dragnet::VerificationResult.new(
            status: :failed,
            reason: "Unable to diff the revisions: #{shorten_sha1(sha1)}..#{shorten_sha1(repository.head.sha)}: " \
              "#{error.result.stdout}"
          )
        end
      end
    end
  end
end
