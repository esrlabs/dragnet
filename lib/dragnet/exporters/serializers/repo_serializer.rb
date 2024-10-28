# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'

module Dragnet
  module Exporters
    module Serializers
      # Serializes a +Repo+ object into a +Hash+
      class RepoSerializer
        attr_reader :repo

        # @param [Dragnet::Repo] repo The +Repo+ object to serialize.
        def initialize(repo)
          @repo = repo
        end

        # Serializes the given +Repo+ object.
        # @return [Hash] A +Hash+ representing the given +Repo+ object.
        def serialize
          {
            path: repo.path,
            sha1: repo.sha1
          }.tap do |hash|
            hash[:files] = serialize_files if repo.files.present?
          end
        end

        private

        # Serializes the array of files attached to the +Repo+
        # @return [Array<String>] The array of file names (without the path to
        #   the repository).
        def serialize_files
          repo.files.map { |file| file.to_s.gsub("#{repo.path}/", '') }
        end
      end
    end
  end
end
