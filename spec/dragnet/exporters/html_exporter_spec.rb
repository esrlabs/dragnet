# frozen_string_literal: true

require 'dragnet/exporters/html_exporter'

RSpec.describe Dragnet::Exporters::HTMLExporter, requirements: ['SRS_DRAGNET_0022'] do
  subject(:html_exporter) do
    described_class.new(
      test_records: test_records, errors: errors, repository: repository, logger: logger
    )
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
      Dragnet::CLI::Logger,
      info: true
    )
  end

  let(:template) do
    <<~ERB
      <!-- Some HTML -->
    ERB
  end

  let(:output) { '' }

  let(:erb) do
    instance_double(
      ERB,
      result: output
    )
  end

  before do
    allow(File).to receive(:read).with(described_class::TEMPLATE).and_return(template)
    allow(ERB).to receive(:new).and_return(erb)
  end

  describe '#export' do
    subject(:method_call) { html_exporter.export }

    it 'logs the template being used for export' do
      expect(logger).to receive(:info).with(
        "Generating HTML report from template: #{described_class::TEMPLATE}..."
      )

      method_call
    end

    it 'reads the template and passes it down to ERB' do
      expect(File).to receive(:read).with(described_class::TEMPLATE).and_return(template)
      expect(ERB).to receive(:new).with(template)
      method_call
    end

    it "calls result on ERB and passes the class's bindings to it" do
      expect(erb).to receive(:result).with(instance_of(Binding))
      method_call
    end

    it "returns the output returned by ERB's #result method" do
      expect(method_call).to eq(output)
    end
  end
end
