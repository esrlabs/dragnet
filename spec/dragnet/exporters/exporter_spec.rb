# frozen_string_literal: true

require 'dragnet/exporters/exporter'

RSpec.describe Dragnet::Exporters::Exporter do
  subject(:exporter) do
    described_class.new(test_records: test_records, errors: errors, repository: repository, logger: logger)
  end

  let(:test_records) { [] }
  let(:errors) { [] }

  let(:repository) do
    instance_double(
      Dragnet::Repository
    )
  end

  let(:logger) do
    instance_double(
      Logger
    )
  end

  describe '#export' do
    subject(:method_call) { exporter.export }

    it 'raises a NotImplementedError' do
      expect { method_call }.to raise_error(
        NotImplementedError,
        "'export' method not implemented for class Dragnet::Exporters::Exporter"
      )
    end
  end
end
