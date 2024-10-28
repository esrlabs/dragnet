# frozen_string_literal: true

require_relative '../../repo'
require_relative 'field_validator'

module Dragnet
  module Validators
    module Fields
      # Validates that the +repos+ attribute in an MTR is valid. This means:
      # * It is either a +Hash+ or an +Array+ of +Hash+es.
      # * The attributes inside each of the +Hash+es are also valid.
      class ReposValidator < Dragnet::Validators::Fields::FieldValidator
        # Validates the MTR's +repos+ field.
        # @param [String] key The name of the key (usually +'repos'+)
        # @param [Object] value The value associated to the attribute.
        # @return [Array<Dragnet::Repo>, nil] If +value+ is a valid +Hash+ or a
        #   valid +Array+ of +Hash+es an +Array+ of +Dragnet::Repo+ objects is
        #   returned. If +value+ is +nil+, +nil+ is returned.
        # @raise [Dragnet::Errors::ValidationError] If +value+ is not a +Hash+
        #   or an +Array+ of +Hash+es or the attributes inside the +Hash+es are
        #   invalid.
        # @see Dragnet::Repo#validate
        def validate(key, value)
          return unless value

          validate_type(key, value, Hash, Array)

          if value.is_a?(Array)
            return if value.empty?

            validate_array_types(key, value, Hash)
          else
            # This is needed because trying to apply the splat operator over a
            # Hash will result in an Array of Arrays (one for each of the Hash's
            # key pairs).
            value = [value]
          end

          create_repos(value)
        end

        private

        # @param [Array<Hash>] hashes The array of +Hash+es from which the Repo
        #   objects shall be created.
        # @return [Array<Dragnet::Repo>] The array of +Dragnet::Repo+ objects
        #   that result from using each of the given +Hash+es as parameters for
        #   the constructor.
        # @raise [Dragnet::Errors::ValidationError] If the attributes inside the
        #   +Hash+es are invalid.
        # @see Dragnet::Repo#validate
        def create_repos(hashes)
          hashes.map do |hash|
            repo = Dragnet::Repo.new(**hash)
            repo.validate
            repo
          end
        end
      end
    end
  end
end
