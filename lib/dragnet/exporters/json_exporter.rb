# frozen_string_literal: true

require 'json'

require_relative 'exporter'
require_relative 'id_generator'
require_relative 'serializers/test_record_serializer'

module Dragnet
  module Exporters
    # Exports the results for the Manual Test Record verification to a JSON
    # string.
    class JSONExporter < ::Dragnet::Exporters::Exporter
      # @return [String] A JSON string containing an array of objects, one for
      #   each Test Record.
      def export
        logger.info 'Exporting data to JSON'
        test_records.map do |test_record|
          ::Dragnet::Exporters::Serializers::TestRecordSerializer
            .new(test_record, repository).serialize
            .merge(id: id_generator.id_for(test_record))
        end.to_json
      end

      private

      # @return [Dragnet::Exporters::IDGenerator] An instance of the IDGenerator
      #   class that can be used to calculate the ID for the exported MTRs.
      def id_generator
        @id_generator ||= ::Dragnet::Exporters::IDGenerator.new(repository)
      end
    end
  end
end
