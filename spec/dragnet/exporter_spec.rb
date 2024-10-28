# frozen_string_literal: true

require 'dragnet/exporter'

RSpec.describe Dragnet::Exporter do
  subject(:exporter) do
    described_class.new(
      test_records: test_records, errors: errors, repository: repository, targets: targets, logger: logger
    )
  end

  let(:test_records) { [] }
  let(:errors) { [] }
  let(:repository) { instance_double(Dragnet::Repository) }
  let(:targets) { %w[output/export.html] }

  let(:logger) do
    instance_double(
      Dragnet::CLI::Logger,
      debug: true,
      info: true
    )
  end

  describe '#export' do
    subject(:method_call) { exporter.export }

    let(:html_output) do
      <<~HTML
        <html>
          <head>
            <title>Test Output</title>
          </head>
        </html>
      HTML
    end

    let(:html_exporter) do
      instance_double(
        Dragnet::Exporters::HTMLExporter,
        export: html_output
      )
    end

    let(:json_output) do
      <<~JSON
        [
          {"first":  "MTR"},
          {"second":  "MTR"}
        ]
      JSON
    end

    let(:json_exporter) do
      instance_double(
        Dragnet::Exporters::JSONExporter,
        export: json_output
      )
    end

    before do
      allow(Dragnet::Exporters::HTMLExporter)
        .to receive(:new).and_return(html_exporter)

      allow(Dragnet::Exporters::JSONExporter)
        .to receive(:new).and_return(json_exporter)

      allow(File).to receive(:write).and_return(2459)
    end

    context 'when one of the target files has an unknown format' do
      let(:targets) { %w[output/report.HTML output/report.log] }

      it 'raises a Dragnet::Errors::UnknownExportFormatError' do
        expect { method_call }.to raise_error(
          Dragnet::Errors::UnknownExportFormatError,
          "Unknown export format: '.log'. Valid export formats are: .html, .htm, .json"
        )
      end
    end

    describe 'exporters creation (one for each target type)' do
      let(:targets) { %w[output/report.html output/report.json] }

      it 'creates an HTML exporter' do
        expect(Dragnet::Exporters::HTMLExporter).to receive(:new).with(
          test_records: test_records, errors: errors, repository: repository, logger: logger
        )

        method_call
      end

      it 'calls export on the HTML exporter' do
        expect(html_exporter).to receive(:export)
        method_call
      end

      it 'creates a JSON exporter' do
        expect(Dragnet::Exporters::JSONExporter).to receive(:new).with(
          test_records: test_records, errors: errors, repository: repository, logger: logger
        )

        method_call
      end

      it 'calls export on the JSON exporter' do
        expect(json_exporter).to receive(:export)
        method_call
      end
    end

    it 'writes the output to the target file' do
      expect(File).to receive(:write).with(targets.first, html_output)
      method_call
    end

    context 'when targets with multiple formats are given' do
      let(:targets) { %w[output/report.html output/report.json] }

      it 'creates an exporter for the HTML report' do
        expect(Dragnet::Exporters::HTMLExporter).to receive(:new).once
        method_call
      end

      it 'writes the output to the HTML target' do
        expect(File).to receive(:write).with('output/report.html', html_output)
        method_call
      end

      it 'creates an exporter for the JSON report' do
        expect(Dragnet::Exporters::JSONExporter).to receive(:new).once
        method_call
      end

      it 'writes the output to the JSON target', requirements: %w[DRAGNET_0060] do
        expect(File).to receive(:write).with('output/report.json', json_output)
        method_call
      end
    end

    context 'when multiple output files with the same format are given' do
      let(:targets) { %w[output/report.html output/other-report.htm] }

      it 'creates ONLY ONE exporter for each format' do
        expect(Dragnet::Exporters::HTMLExporter).to receive(:new).once
        method_call
      end

      it 'writes the output to all given targets' do
        targets.each do |target|
          expect(File).to receive(:write).with(target, html_output)
        end

        method_call
      end
    end

    context 'when the output file cannot be written' do
      before do
        allow(File).to receive(:write).and_raise(
          Errno::EACCES, 'Read only file system'
        )
      end

      it 'raises a Dragnet::Errors::UnableToWriteReportError' do
        expect { method_call }
          .to raise_error(
            Dragnet::Errors::UnableToWriteReportError,
            'Unable to write report output to output/export.html: Permission denied - Read only file system'
          )
      end
    end
  end
end
